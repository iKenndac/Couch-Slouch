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

static NSString * const kGroupsFileGroupsKey = @"Groups";
static NSString * const kGroupsFileGroupTitleKeyKey = @"Name";
static NSString * const kGroupsFileGroupButtonsKey = @"Buttons";

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
		self.groups = [dict valueForKey:kGroupsFileGroupsKey];
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

#pragma mark - IBActions

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
