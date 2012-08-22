//
//  DKKeybindsViewController.m
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKKeybindsViewController.h"
#import "SRRecorderControl.h"

@interface DKKeybindsViewController ()

@end

@implementation DKKeybindsViewController
@synthesize recorder;
@synthesize sourceList;
@synthesize openPanelView;

-(id)init {
	return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[[DKCECKeyMappingController sharedController] addObserver:self forKeyPath:@"applicationMappings" options:0 context:nil];
    }
    
    return self;
}

-(void)dealloc {
	[[DKCECKeyMappingController sharedController] removeObserver:self forKeyPath:@"applicationMappings"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"applicationMappings"]) {
        [self.sourceList reloadData];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)awakeFromNib {
	[self tableViewSelectionDidChange:nil];
	[self.recorder setAllowsKeyOnly:YES escapeKeysRecord:YES];
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

#pragma mark - TableView

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSView *view = [tableView makeViewWithIdentifier:tableColumn == nil ? @"divider" : @"cell" owner:self];
	return view;
}

-(BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return NO;
	return row == controller.applicationMappings.count;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return YES;
	return !(row == controller.applicationMappings.count);
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
	DKCECKeyMapping *mapping = [self tableView:self.sourceList objectValueForTableColumn:nil row:self.sourceList.selectedRow];
	self.currentMapping = mapping;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return 38.0;
	return row == controller.applicationMappings.count ? 16.0 : 38.0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return 1;
	return controller.applicationMappings.count + 2;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	DKCECKeyMappingController *controller = [DKCECKeyMappingController sharedController];
	if (controller.applicationMappings.count == 0) return controller.baseMapping;
	if (rowIndex == controller.applicationMappings.count) return nil; // Divider.
	if (rowIndex == controller.applicationMappings.count + 1) return controller.baseMapping;
	return [controller.applicationMappings objectAtIndex:rowIndex];
}

@end
