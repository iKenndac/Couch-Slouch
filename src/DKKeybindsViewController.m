//
//  DKKeybindsViewController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKKeybindsViewController.h"
#import "SRRecorderControl.h"
#import "DKCECDeviceController+KeyCodeTranslation.h"
#import "Constants.h"

static NSString * const kGroupsFileGroupsKey = @"Groups";
static NSString * const kGroupsFileGroupTitleKeyKey = @"Name";
static NSString * const kGroupsFileGroupButtonsKey = @"Buttons";
static NSString * const kGroupsFileDebugGroupName = @"DebugGroupTitle";

@interface DKKeybindsViewController ()

@property (nonatomic, readwrite, strong) NSArray *groups;

@end

@implementation DKKeybindsViewController
@synthesize recorder;
@synthesize sourceList;
@synthesize openPanelView;
@synthesize actionsList;

-(id)init {
	return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[[DKCECKeyMappingController sharedController] addObserver:self forKeyPath:@"applicationMappings" options:0 context:nil];
		[self addObserver:self forKeyPath:@"currentMapping.actions" options:0 context:nil];

		NSURL *groupsFile = [[NSBundle mainBundle] URLForResource:@"ButtonGroups" withExtension:@"plist"];
		NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfURL:groupsFile]
																	   options:0
																		format:nil
																		 error:nil];

		NSArray *groups = [dict valueForKey:kGroupsFileGroupsKey];

#if !DEBUG
		NSMutableArray *strippedArray = [groups mutableCopy];
		for (NSDictionary *group in groups) {
			if ([group[kGroupsFileGroupTitleKeyKey] isEqualToString:kGroupsFileDebugGroupName]) {
				[strippedArray removeObject:group];
			}
		}

		groups = [NSArray arrayWithArray:strippedArray];
#endif

			self.groups = groups;
    }
    
    return self;
}

-(void)dealloc {
	[[DKCECKeyMappingController sharedController] removeObserver:self forKeyPath:@"applicationMappings"];
	[self removeObserver:self forKeyPath:@"currentMapping.actions"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"applicationMappings"]) {
        [self.sourceList reloadData];
	} else if ([keyPath isEqualToString:@"currentMapping.actions"]) {
		[self.actionsList reloadData];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)awakeFromNib {
	[self tableViewSelectionDidChange:nil];
	[self.recorder setAllowsKeyOnly:YES escapeKeysRecord:YES];
	self.actionsList.floatsGroupRows = YES;
}

#pragma mark -

-(NSArray *)flattenedMappingList {
	NSMutableArray *list = [NSMutableArray array];
	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	[list addObjectsFromArray:controller.applicationMappings];
	[list addObject:controller.baseMapping];
	return list;
}

-(void)displayErrorToUser:(NSError *)error {
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

+(NSSet *)keyPathsForValuesAffectingCanExportSelectedBindings {
	return [NSSet setWithObject:@"currentMapping"];
}

-(BOOL)canExportSelectedBindings {
	return self.currentMapping.applicationIdentifier.length > 0;
}

+(NSSet *)keyPathsForValuesAffectingExportBindingsMenuTitle {
	return [NSSet setWithObject:@"currentMapping"];
}

-(NSString *)exportBindingsMenuTitle {
	if (self.currentMapping.applicationIdentifier.length > 0) {
		return [NSString stringWithFormat:NSLocalizedString(@"export keybinding title", @""), self.currentMapping.lastKnownName];
	}

	return NSLocalizedString(@"can't export keybinding title", @"");
}

#pragma mark - Keyboard

-(void)deleteBackward:(id)sender {

	if (self.currentMapping.applicationIdentifier.length > 0) {

		DKCECKeyMapping *mapping = self.currentMapping;

		NSAlert *deleteAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"keybinding delete alert title", @""), mapping.lastKnownName]
											   defaultButton:NSLocalizedString(@"cancel button title", @"")
											 alternateButton:NSLocalizedString(@"trash button title", @"")
												 otherButton:nil
								   informativeTextWithFormat:NSLocalizedString(@"keybinding delete alert description", @"")];

		[deleteAlert beginSheetModalForWindow:self.view.window
								modalDelegate:self
							   didEndSelector:@selector(keybindDeleteAlertDidEnd:returnCode:contextInfo:)
								  contextInfo:(__bridge void *)mapping];

	} else {
		NSBeep();
	}
}

-(void)keybindDeleteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertAlternateReturn) {
		DKCECKeyMapping *mapping = (__bridge DKCECKeyMapping *)contextInfo;
		[self deleteMapping:mapping];
	}
}

#pragma mark - Key Mappings Management

-(void)deleteMapping:(DKCECKeyMapping *)mapping {

	// First, export the mapping, then trash it.
	NSString *fileName = [[NSString stringWithFormat:NSLocalizedString(@"keybindings file name formatter", @""), mapping.lastKnownName]
						  stringByAppendingPathExtension:kKeybindingsFileNameExtension];

	NSURL *fileURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:fileName];

	NSError *exportError = nil;
	if (![self exportMapping:mapping toURL:fileURL error:&exportError]) {
		[self displayErrorToUser:exportError];
		return;
	}

	[[NSWorkspace sharedWorkspace] recycleURLs:@[fileURL] completionHandler:^(NSDictionary *newURLs, NSError *error) {
		if (error != nil) {
			[self displayErrorToUser:nil];
		} else {
			// If we get here, the export and trash operation went successfully, so we can remove the mapping.
			[[DKCECKeyMappingController sharedController] removeMapping:mapping];
		}
	}];
}

-(BOOL)exportMapping:(DKCECKeyMapping *)mapping toURL:(NSURL *)aURL error:(NSError **)error {
	id plist = [mapping propertyListRepresentation];
	NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist
															  format:NSPropertyListXMLFormat_v1_0
															 options:0
															   error:error];

	if (!data) return NO;
	return [data writeToURL:aURL options:NSDataWritingAtomic error:error];
}

#pragma mark - IBActions

-(IBAction)exportKeyBinding:(id)sender {

	if (self.currentMapping.applicationIdentifier.length == 0) {
		NSBeep();
		return;
	}

	DKCECKeyMapping *mapping = self.currentMapping;

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = [NSString stringWithFormat:NSLocalizedString(@"keybindings file name formatter", @""), mapping.lastKnownName];
	savePanel.allowedFileTypes = @[kKeybindingsFileNameExtension];
	savePanel.allowsOtherFileTypes = NO;

	[savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {

		if (result != NSFileHandlingPanelOKButton) return;

		NSError *error = nil;
		if (![self exportMapping:mapping toURL:savePanel.URL error:&error]) {
			[self displayErrorToUser:error];
		}
	}];

}

-(IBAction)importKeyBinding:(id)sender {

	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
	openPanel.allowedFileTypes = @[kKeybindingsFileNameExtension];
	openPanel.allowsOtherFileTypes = NO;

	[openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {

		if (result != NSFileHandlingPanelOKButton) return;
		[self attemptToImportKeybinding:openPanel.URL];
	}];
}

-(void)attemptToImportKeybinding:(NSURL *)keyBindingURL {

	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:keyBindingURL options:0 error:&error];

	if (data == nil) {
		[self displayErrorToUser:error];
		return;
	}

	id plistRep = [NSPropertyListSerialization propertyListWithData:data
															options:0
															 format:nil
															  error:&error];

	if (plistRep == nil) {
		[self displayErrorToUser:error];
		return;
	}

	DKCECKeyMapping *mapping = [[DKCECKeyMapping alloc] initWithPropertyListRepresentation:plistRep];
	if (mapping == nil) {
		[self displayErrorToUser:nil];
		return;
	}

	DKCECKeyMapping *existingMapping = [[DKCECKeyMappingController sharedController] keyMappingForApplicationWithIdentifier:mapping.applicationIdentifier];

	if (existingMapping == nil) {
		[[DKCECKeyMappingController sharedController] addMapping:mapping];
	} else {

		NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"keybinding exists alert title", @""), mapping.lastKnownName]
										 defaultButton:NSLocalizedString(@"cancel button title", @"")
									   alternateButton:NSLocalizedString(@"replace button title", @"")
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"keybinding exists alert description", @"")];

		if ([alert runModal] == NSAlertAlternateReturn) {
			[[DKCECKeyMappingController sharedController] removeMapping:existingMapping];
			[[DKCECKeyMappingController sharedController] addMapping:mapping];
		}

	}
}

-(IBAction)addApplication:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.accessoryView = self.openPanelView;
	openPanel.delegate = self;
    openPanel.message = NSLocalizedString(@"please choose the application title", @"");
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = YES;

	self.chosenSourceMapping = self.currentMapping;

	[openPanel beginSheetModalForWindow:self.view.window
					  completionHandler:^(NSInteger result) {

						  if (result != NSFileHandlingPanelOKButton) return;

						  NSBundle *appBundle = [NSBundle bundleWithURL:openPanel.URL];
						  if (appBundle.bundleIdentifier.length > 0) {
							  DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
							  DKCECKeyMapping *mappingToDuplicate = self.chosenSourceMapping;
							  if (mappingToDuplicate == nil) mappingToDuplicate = [controller baseMapping];
							  [controller duplicateMapping:mappingToDuplicate withNewApplicationIdentifier:appBundle.bundleIdentifier];
						  } else {
							  [[NSAlert alertWithMessageText:NSLocalizedString(@"invalid application chosen title", @"")
											   defaultButton:NSLocalizedString(@"ok button title", @"")
											 alternateButton:@""
												 otherButton:@""
								   informativeTextWithFormat:NSLocalizedString(@"invalid application chosen description", @"")]
							   runModal];
						  }
					  }];
}

-(BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {

    NSString *path = [url path];
    if ([[path pathExtension] compare:@"app" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    } else {
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        return isDir;
    }
    return NO;
}

-(BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
	
	NSString *path = [url path];
    if ([[path pathExtension] compare:@"app" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    } else {
		if (outError != NULL)
			*outError = [NSError errorWithDomain:@"error"
											code:0
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"invalid application chosen title", @""), NSLocalizedDescriptionKey,
												  NSLocalizedString(@"invalid application chosen description", @""), NSLocalizedRecoverySuggestionErrorKey,
												  nil]];

		return NO;
	}
}

-(void)handleKeypress:(cec_keypress)press {

	NSString *keyString = [DKCECDeviceController stringForKeyCode:press.keycode];
	NSInteger whereWereAt = 0;

	for (NSDictionary *group in self.groups) {
		whereWereAt++; // Take into account the header row itself.

		for (NSString *button in [group valueForKey:kGroupsFileGroupButtonsKey]) {
			if ([button caseInsensitiveCompare:keyString] == NSOrderedSame) {
				[self.actionsList selectRowIndexes:[NSIndexSet indexSetWithIndex:whereWereAt] byExtendingSelection:NO];
				[self.actionsList scrollRowToVisible:whereWereAt];
				[self.view.window makeFirstResponder:self.actionsList];
				return;
			}
			whereWereAt++;
		}
	}

	NSLog(@"[%@ %@]: Got unlisted key: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), keyString);
}

#pragma mark - TableView (Source List)

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (tableView == self.actionsList)
		return [self actionsTableView:tableView viewForTableColumn:tableColumn row:row];
	
	NSView *view = [tableView makeViewWithIdentifier:tableColumn == nil ? @"divider" : @"cell" owner:nil];
	return view;
}

-(BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
	if (tableView == self.actionsList)
		return [self actionsTableView:tableView isGroupRow:row];
	
	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return NO;
	return row == controller.applicationMappings.count;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	if (tableView == self.actionsList)
		return [self actionsTableView:tableView shouldSelectRow:row];

	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return YES;
	return !(row == controller.applicationMappings.count);
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
	if (notification.object == self.actionsList) {
		[self actionsTableViewSelectionDidChange:notification];
		return;
	}

	DKCECKeyMapping *mapping = [self tableView:self.sourceList objectValueForTableColumn:nil row:self.sourceList.selectedRow];
	self.currentMapping = mapping;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	if (tableView == self.actionsList)
		return [self actionsTableView:tableView heightOfRow:row];

	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return 38.0;
	return row == controller.applicationMappings.count ? 16.0 : 38.0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	if (aTableView == self.actionsList)
		return [self numberOfRowsInActionsTableView:aTableView];

	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return 1;
	return controller.applicationMappings.count + 2;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if (aTableView == self.actionsList)
		return [self actionsTableView:aTableView objectValueForTableColumn:aTableColumn row:rowIndex];

	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return controller.baseMapping;
	if (rowIndex == controller.applicationMappings.count) return nil; // Divider.
	if (rowIndex == controller.applicationMappings.count + 1) return controller.baseMapping;
	return [controller.applicationMappings objectAtIndex:rowIndex];
}

#pragma mark - TableView (Actions List)

-(NSView *)actionsTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

	if (tableColumn == nil) {
		NSTableCellView *view = [tableView makeViewWithIdentifier:@"divider" owner:nil];
		[view.textField.cell setBackgroundStyle:NSBackgroundStyleRaised];
		return view;
	}
	return [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
}

-(BOOL)actionsTableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {

	NSMutableIndexSet *headerIndexes = [NSMutableIndexSet indexSet];
	NSInteger whereWereAt = -1;

	for (NSDictionary *group in self.groups) {
		whereWereAt++; // Take into account the header row itself.
		[headerIndexes addIndex:whereWereAt];
		NSArray *buttons = [group valueForKey:kGroupsFileGroupButtonsKey];
		whereWereAt += buttons.count;
	}
	return [headerIndexes containsIndex:row];
}

-(BOOL)actionsTableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	return ![self actionsTableView:tableView isGroupRow:row];
}

-(void)actionsTableViewSelectionDidChange:(NSNotification *)notification {

}

-(CGFloat)actionsTableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	return [self actionsTableView:tableView isGroupRow:row] ? 17.0 : 38.0;
}

-(NSInteger)numberOfRowsInActionsTableView:(NSTableView *)aTableView {
	NSUInteger rows = self.groups.count;
	for (NSDictionary *group in self.groups) {
		NSArray *buttons = [group valueForKey:kGroupsFileGroupButtonsKey];
		rows += buttons.count;
	}
	return rows;
}

-(id)actionsTableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {

	NSInteger whereWereAt = -1;

	for (NSDictionary *group in self.groups) {
		whereWereAt++; // Take into account the header row itself.
		
		if (whereWereAt == rowIndex)
			return NSLocalizedString([group valueForKey:kGroupsFileGroupTitleKeyKey], @"");

		NSArray *buttons = [group valueForKey:kGroupsFileGroupButtonsKey];
		NSRange ourRowRange = NSMakeRange(whereWereAt + 1, buttons.count);

		if (rowIndex >= ourRowRange.location && rowIndex < ourRowRange.location + ourRowRange.length) {
			NSString *button = [buttons objectAtIndex:rowIndex - ourRowRange.location];
			cec_keypress press;
			press.keycode = [DKCECDeviceController keyCodeForString:button];
			press.duration = 0;
			return [self.currentMapping actionForKeyPress:press];
		}
		
		whereWereAt += buttons.count;
	}
	return nil;
}

@end
