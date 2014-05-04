//
//  DKCECKeyMapping.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKCECKeyMappingController.h"
#import "DKDoNothingLocalAction.h"
#import "DKCECDeviceController+KeyCodeTranslation.h"
#import "Constants.h"

static NSString * const kBaseMappingUserDefaultsKey = @"BaseMapping";
static NSString * const kAppMappingsUserDefaultsKey = @"ApplicationMappings";

@interface DKCECKeyMappingController ()

@property (nonatomic, readwrite, strong) NSMutableDictionary *mappingStorage;
@property (nonatomic, readwrite, strong) NSDictionary *aliasStorage;
@property (nonatomic, readwrite, strong) DKCECKeyMapping *baseMapping;

@end

@implementation DKCECKeyMappingController

static DKCECKeyMappingController *sharedController;

+(DKCECKeyMappingController *)sharedController {
	if (sharedController == nil)
		sharedController = [DKCECKeyMappingController new];
	return sharedController;
}

-(id)init {
	self = [super init];
	if (self) {

		self.mappingStorage = [NSMutableDictionary new];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		NSURL *keysFile = [[NSBundle mainBundle] URLForResource:@"DefaultKeybinds" withExtension:@"plist"];
		NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfURL:keysFile]
																	   options:0
																		format:nil
																		 error:nil];

		[defaults registerDefaults:dict];

		NSDictionary *base = [defaults valueForKey:kBaseMappingUserDefaultsKey];
		self.baseMapping = [[DKCECKeyMapping alloc] initWithPropertyListRepresentation:base];

		NSArray *appMappings = [defaults valueForKey:kAppMappingsUserDefaultsKey];
		for (NSDictionary *dict in appMappings) {
			DKCECKeyMapping *mapping = [[DKCECKeyMapping alloc] initWithPropertyListRepresentation:dict];
			if (mapping)
				[self.mappingStorage setValue:mapping forKey:mapping.applicationIdentifier];
		}

		[self saveMappings];


		NSURL *aliasFile = [[NSBundle mainBundle] URLForResource:@"KeyAliases" withExtension:@"plist"];
		NSDictionary *aliases = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfURL:aliasFile]
																		  options:0
																		   format:nil
																			error:nil];
		self.aliasStorage = aliases;
	}
	return self;
}

-(cec_user_control_code)keyCodeByResolvingAliasesFromKeyCode:(cec_user_control_code)code {

	NSString *codeString = [DKCECDeviceController stringForKeyCode:code];
	NSString *resolvedCodeString = [self.aliasStorage valueForKey:codeString];

	if (resolvedCodeString.length == 0)
		return code;

	cec_user_control_code resolvedCode = [DKCECDeviceController keyCodeForString:resolvedCodeString];

	if (resolvedCode == CEC_USER_CONTROL_CODE_UNKNOWN)
		return code;

	return resolvedCode;
}

-(void)dealloc {
	[self saveMappings];
}

-(DKCECKeyMapping *)keyMappingForApplicationWithIdentifier:(NSString *)appIdentifier {
	return [self.mappingStorage valueForKey:appIdentifier];
}

-(DKCECKeyMapping *)duplicateMapping:(DKCECKeyMapping *)mapping withNewApplicationIdentifier:(NSString *)appIdentifier {
	if (appIdentifier.length == 0) return nil;
	[self willChangeValueForKey:@"applicationMappings"];
	DKCECKeyMapping *newMapping = [mapping copy];
	newMapping.applicationIdentifier = appIdentifier;
	[self.mappingStorage setValue:newMapping forKey:appIdentifier];
	[self didChangeValueForKey:@"applicationMappings"];
	[self performSelector:@selector(saveMappings) withObject:nil afterDelay:5.0];
	return newMapping;
}

-(void)removeMapping:(DKCECKeyMapping *)mapping {
	if (mapping.applicationIdentifier != nil) {
		[self willChangeValueForKey:@"applicationMappings"];
		[self.mappingStorage removeObjectForKey:mapping.applicationIdentifier];
		[self didChangeValueForKey:@"applicationMappings"];
	}
}

-(void)saveMappings {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[self.baseMapping propertyListRepresentation] forKey:kBaseMappingUserDefaultsKey];

	NSMutableArray *mappings = [NSMutableArray new];

	for (NSString *key in [self.mappingStorage allKeys]) {
		DKCECKeyMapping *mapping = [self.mappingStorage valueForKey:key];
		[mappings addObject:[mapping propertyListRepresentation]];
	}

	[defaults setValue:mappings forKey:kAppMappingsUserDefaultsKey];
}

-(NSArray *)applicationMappings {
	return [[self.mappingStorage allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		DKCECKeyMapping *mapping1 = obj1;
		DKCECKeyMapping *mapping2 = obj2;
		return ([mapping1.lastKnownName caseInsensitiveCompare:mapping2.lastKnownName]);
	}];
	//TODO: This API is slow and dumb
}

@end

static NSString * const kKeyMappingApplicationIdentifierKey = @"identifier";
static NSString * const kKeyMappingLastKnownNameKey = @"name";
static NSString * const kKeyMappingActionsKey = @"actions";

@interface DKCECKeyMapping ()

@property (nonatomic, readwrite, copy) NSString *lastKnownName;
@property (nonatomic, readwrite, copy) NSArray *actions;
@property (nonatomic, readwrite, strong) NSImage *cachedDisplayImage;

@end

@implementation DKCECKeyMapping

-(id)init {
	return [self initWithPropertyListRepresentation:nil];
}

-(id)initWithPropertyListRepresentation:(NSDictionary *)plist {

	self = [super init];
	if (self) {

		[self addObserver:self forKeyPath:@"applicationIdentifier" options:0 context:nil];

		self.lastKnownName = [plist valueForKey:kKeyMappingLastKnownNameKey];
		self.applicationIdentifier = [plist valueForKey:kKeyMappingApplicationIdentifierKey];

		NSArray *actionRepresentations = [plist valueForKey:kKeyMappingActionsKey];
		NSMutableArray *mutableActions = [NSMutableArray arrayWithCapacity:actionRepresentations.count];

		for (NSDictionary *dict in actionRepresentations) {

			id <DKLocalAction> action = [DKLocalAction localActionWithPropertyList:dict];

			if (action) {
				action.parentMapping = self;
				[mutableActions addObject:action];
			}
		}
		self.actions = [NSArray arrayWithArray:mutableActions];
	}

	return self;
}

-(id)copyWithZone:(NSZone *)zone {
	return [[DKCECKeyMapping alloc] initWithPropertyListRepresentation:[self propertyListRepresentation]];
}

-(void)dealloc {
	[self removeObserver:self forKeyPath:@"applicationIdentifier"];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"applicationIdentifier"]) {

		NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:self.applicationIdentifier];
		if (appPath.length == 0) return;
		NSBundle *appBundle = [[NSBundle alloc] initWithPath:appPath];
		NSString *bundleName = [[appBundle infoDictionary] valueForKey:(__bridge NSString *)kCFBundleNameKey];
		if (bundleName.length > 0)
			self.lastKnownName = bundleName;
		else
			self.lastKnownName = [[appPath lastPathComponent] stringByDeletingPathExtension];

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(NSDictionary *)propertyListRepresentation {

	NSMutableDictionary *plist = [NSMutableDictionary new];
	[plist setValue:self.applicationIdentifier forKey:kKeyMappingApplicationIdentifierKey];
	[plist setValue:self.lastKnownName forKey:kKeyMappingLastKnownNameKey];

	NSArray *actionReps = [self.actions valueForKey:@"propertyListRepresentation"];
	[plist setValue:actionReps forKey:kKeyMappingActionsKey];

	return plist;
}

-(id <DKLocalAction>)actionForKeyPress:(cec_keypress)keypress {

	for (id <DKLocalAction> potentialAction in self.actions) {
		if ([potentialAction matchesKeyPress:keypress])
			return potentialAction;
	}

	// If we get here, there's no action for the given keypress. Maybe
	// the user messed around with the plist, or we added new keycodes.
	DKLocalAction *action = [[DKDoNothingLocalAction alloc] initWithDeviceKeyCode:keypress.keycode];
	[self addAction:action];
	return action;
}

-(void)addAction:(id <DKLocalAction>)action {
	if (action) [self addActions:@[action]];
}

-(void)removeAction:(id <DKLocalAction>)action {
	if (action) [self removeActions:@[action]];
}

-(void)addActions:(NSArray *)actions {
	[actions makeObjectsPerformSelector:@selector(setParentMapping:) withObject:self];
	self.actions = [self.actions arrayByAddingObjectsFromArray:actions];
}

-(void)removeActions:(NSArray *)actions {
	NSMutableArray *mutableActions = [self.actions mutableCopy];
	[mutableActions removeObjectsInArray:actions];
	[actions makeObjectsPerformSelector:@selector(setParentMapping:) withObject:nil];
	self.actions = [NSArray arrayWithArray:mutableActions];
}

-(void)replaceAction:(id <DKLocalAction>)action withAction:(id <DKLocalAction>)newAction {

	if (action == nil || newAction == nil) return;
	NSInteger index = [self.actions indexOfObject:action];
	if (index == NSNotFound) return;

	NSMutableArray *mutableActions = [self.actions mutableCopy];
	[mutableActions removeObjectAtIndex:index];
	[mutableActions insertObject:newAction atIndex:index];
	newAction.parentMapping = self;
	action.parentMapping = nil;
	self.actions = [NSArray arrayWithArray:mutableActions];
}

+(NSSet *)keyPathsForValuesAffectingDisplayName {
	return [NSSet setWithObjects:@"applicationIdentifier", @"lastKnownName", nil];
}

-(NSString *)displayName {
	if (self.applicationIdentifier.length == 0) {
		if ([DKCECKeyMappingController sharedController].applicationMappings.count == 0)
			return NSLocalizedString(@"all applications title", @"");
		else
			return NSLocalizedString(@"all other applications title", @"");
	}
	if (self.lastKnownName.length == 0) return self.applicationIdentifier;
	return self.lastKnownName;
}

+(NSSet *)keyPathsForValuesAffectingDisplayImage {
	return [NSSet setWithObjects:@"applicationIdentifier", nil];
}

-(NSImage *)displayImage {

	if (self.cachedDisplayImage == nil) {
		NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
		NSString *path = [workspace absolutePathForAppBundleWithIdentifier:self.applicationIdentifier];
		if (path.length > 0) self.cachedDisplayImage = [workspace iconForFile:path];

		if (self.cachedDisplayImage == nil)
			self.cachedDisplayImage = [NSImage imageNamed:@"PlainAppIcon"];
	}
	return self.cachedDisplayImage;
}

@end
