//
//  DKDoNothingLocalAction.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKLocalAction.h"
#import "Constants.h"
#import "DKCECDeviceController+KeyCodeTranslation.h"

@interface DKLocalAction ()

@property (nonatomic, readwrite) cec_user_control_code deviceKeyCode;

@end

@implementation DKLocalAction

static NSMutableArray *registeredViewControllers;

+(void)initialize {
	registeredViewControllers = [NSMutableArray new];
}

+(void)registerViewControllerClass:(Class)controllerClass description:(NSString *)desc forLocalActionOfClass:(Class)localActionClass {

	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
	[dict setValue:controllerClass forKey:kActionViewControllerClassKey];
	[dict setValue:desc forKey:kActionViewControllerDescriptionKey];
	[dict setValue:localActionClass forKey:kActionViewControllerActionClassKey];
	[registeredViewControllers addObject:dict];
}

+(NSArray *)registeredConfigViewControllers {
	return [NSArray arrayWithArray:registeredViewControllers];
}

+(id <DKLocalAction>)localActionWithPropertyList:(id)plist {

	NSString *className = [plist valueForKey:kLocalActionPlistRepClassKey];
	Class actionClass = NSClassFromString(className);

	if (actionClass == nil)
		return nil;

	id <DKLocalAction> action = [[actionClass alloc] initWithPropertyListRepresentation:plist];
	return action;
}

-(id)initWithDeviceKeyCode:(cec_user_control_code)deviceCode {
	self = [super init];

	if (self) {
		self.deviceKeyCode = deviceCode;
	}
	return self;
}

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super init];

	if (self) {
		self.deviceKeyCode = [DKCECDeviceController keyCodeForString:[plist valueForKey:kDeviceKeyCodeKey]];
	}
	return self;
}

@synthesize parentMapping;

-(id)propertyListRepresentation { return [NSDictionary dictionary]; }
-(void)performActionWithKeyPress:(cec_keypress)keyPress {}

-(BOOL)matchesKeyPress:(cec_keypress)keyPress {
	return (keyPress.keycode == self.deviceKeyCode ||
	[[DKCECKeyMappingController sharedController] keyCode:keyPress.keycode isAliasForKeyCode:self.deviceKeyCode]);
}

-(NSString *)deviceKeyCodeDisplayName {
	NSString *str = [NSString stringWithFormat:@"CEC_USER_CONTROL_CODE_%@", [DKCECDeviceController stringForKeyCode:self.deviceKeyCode]];
	return NSLocalizedString(str, @"");
}

@end
