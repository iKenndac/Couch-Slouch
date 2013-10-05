//
//  DKBehavioursViewController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKBehavioursViewController.h"
#import "DKCECBehaviourController.h"
#import "DKBehaviourScriptController.h"
#import "Constants.h"

@interface DKBehavioursViewController ()
@property (weak) IBOutlet NSPopUpButton *macAwokePopup;
@property (weak) IBOutlet NSPopUpButton *macSleptPopup;
@property (weak) IBOutlet NSPopUpButton *lostActivePopup;
@property (weak) IBOutlet NSPopUpButton *becameActivePopup;
@property (weak) IBOutlet NSPopUpButton *tvSwitchedOnPopup;
@property (weak) IBOutlet NSPopUpButton *tvSwitchedOffPopup;
@property (nonatomic, readwrite) DKBehaviourScriptController *scriptController;
@end

static void * const kRebuildPopupsKVOContext = @"kRebuildPopupsKVOContext";

@implementation DKBehavioursViewController

-(id)init {
	self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (self) {
		self.scriptController = [DKBehaviourScriptController new];
		[self addObserver:self forKeyPath:@"scriptController.scripts" options:NSKeyValueObservingOptionInitial context:kRebuildPopupsKVOContext];
	}
	return self;
}

-(void)awakeFromNib {
	[self rebuildAllPopups];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == kRebuildPopupsKVOContext) {
		[self rebuildAllPopups];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (IBAction)openScriptsFolder:(id)sender {
	[self.scriptController openUserScriptsFolder];
}

- (IBAction)openWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kCouchSlouchWebsiteScriptingPageURL]];
}

-(IBAction)popupChanged:(id)sender {

	NSPopUpButton *popup = sender;

	NSInteger tag = popup.selectedTag;
	NSURL *scriptURL = popup.selectedItem.representedObject;
	NSString *key = [self userDefaultsKeyForPopup:popup];

	[[NSUserDefaults standardUserDefaults] setInteger:tag forKey:key];
	[[NSUserDefaults standardUserDefaults] setValue:[scriptURL absoluteString] forKey:[key stringByAppendingString:kOnActionScriptUserDefaultsKeySuffix]];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark - Menu Building

-(void)rebuildAllPopups {

	[self rebuildPopup:self.macAwokePopup withTVActions:@[@(DKCECTVBehaviourActionPowerOnTV)]];
	[self rebuildPopup:self.macSleptPopup withTVActions:@[@(DKCECTVBehaviourActionPowerOffTV)]];

	[self rebuildPopup:self.tvSwitchedOffPopup withMacActions:@[@(DKCECBehaviourActionSleepComputer), @(DKCECBehaviourActionShutdownComputer)]];
	[self rebuildPopup:self.tvSwitchedOnPopup withMacActions:nil];
	[self rebuildPopup:self.lostActivePopup withMacActions:@[@(DKCECBehaviourActionSleepComputer), @(DKCECBehaviourActionShutdownComputer)]];
	[self rebuildPopup:self.becameActivePopup withMacActions:nil];

}

-(void)rebuildPopup:(NSPopUpButton *)popup withTVActions:(NSArray *)actions {

	NSMutableArray *items = [NSMutableArray array];

	for (NSNumber *action in actions)
		[items addObject:[self menuItemForTVAction:[action integerValue]]];

	[self rebuildPopup:popup withActionItems:items userDefaultsKey:[self userDefaultsKeyForPopup:popup]];

}

-(void)rebuildPopup:(NSPopUpButton *)popup withMacActions:(NSArray *)actions {

	NSMutableArray *items = [NSMutableArray array];

	for (NSNumber *action in actions)
		[items addObject:[self menuItemForMacAction:[action integerValue]]];

	[self rebuildPopup:popup withActionItems:items userDefaultsKey:[self userDefaultsKeyForPopup:popup]];
}

-(void)rebuildPopup:(NSPopUpButton *)popup withActionItems:(NSArray *)actionMenuItems userDefaultsKey:(NSString *)userDefaultsKey {

	NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:userDefaultsKey];
	NSString *scriptString = [[NSUserDefaults standardUserDefaults] stringForKey:[userDefaultsKey stringByAppendingString:kOnActionScriptUserDefaultsKeySuffix]];
	NSURL *savedScriptURL = scriptString.length > 0 ? [NSURL URLWithString:scriptString] : nil;

	[popup removeAllItems];

	[popup.menu addItem:[self menuItemForMacAction:DKCECBehaviourActionNothing]];

	if (actionMenuItems.count > 0)
		[popup.menu addItem:[NSMenuItem separatorItem]];

	for (NSMenuItem *item in actionMenuItems) {
		[popup.menu addItem:item];
		if (item.tag == action) {
			[popup selectItem:item];
		}
	}

	[popup.menu addItem:[NSMenuItem separatorItem]];

	if (self.scriptController.scripts.count == 0) {
		[popup.menu addItem:[self noScriptsMenuItem]];
	} else {

		for (NSURL *scriptURL in self.scriptController.scripts) {
			NSMenuItem *scriptItem = [self menuItemForScript:scriptURL];
			[popup.menu addItem:scriptItem];
			if (action == DKCECCommonBehaviourActionTriggerScript && [scriptURL isEqual:savedScriptURL]) {
				[popup selectItem:scriptItem];
			}
		}
	}

}

-(NSMenuItem *)menuItemForScript:(NSURL *)scriptURL {

	NSString *name = [[NSFileManager defaultManager] displayNameAtPath:[scriptURL path]];
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[scriptURL path]];
	icon.size = NSMakeSize(16.0, 16.0);

	NSMenuItem *scriptItem = [self menuItemWithTag:DKCECBehaviourActionTriggerScript
											 title:name
											  icon:icon];

	scriptItem.representedObject = scriptURL;

	return scriptItem;
}

-(NSMenuItem *)noScriptsMenuItem {

	NSMenuItem *item = [self menuItemWithTag:DKCECBehaviourActionTriggerScript
						   title:NSLocalizedString(@"no scripts menu title", @"")
							icon:nil];

	[item setEnabled:NO];
	return item;

}

-(NSMenuItem *)menuItemForMacAction:(DKCECMacBehaviourAction)action {

	switch (action) {
		case DKCECBehaviourActionNothing:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"do nothing menu title", @"")
									icon:nil];
			break;

		case DKCECBehaviourActionSleepComputer:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"sleep computer menu title", @"")
									icon:nil];
			break;

		case DKCECBehaviourActionShutdownComputer:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"shutdown computer menu title", @"")
									icon:nil];
			break;

		case DKCECBehaviourActionWakeUpComputer:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"wake computer menu title", @"")
									icon:nil];
			break;

		case DKCECBehaviourActionTriggerScript:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"trigger script menu title", @"")
									icon:nil];
			break;

	}

	return nil;

}

-(NSMenuItem *)menuItemForTVAction:(DKCECTVBehaviourAction)action {

	switch (action) {
		case DKCECTVBehaviourActionNothing:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"do nothing menu title", @"")
									icon:nil];
			break;

		case DKCECTVBehaviourActionPowerOnTV:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"switch on TV menu title", @"")
									icon:nil];
			break;

		case DKCECTVBehaviourActionPowerOffTV:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"switch off TV menu title", @"")
									icon:nil];
			break;

		case DKCECTVBehaviourActionTriggerScript:
			return [self menuItemWithTag:action
								   title:NSLocalizedString(@"trigger script menu title", @"")
									icon:nil];
			break;
			
	}

}

-(NSMenuItem *)menuItemWithTag:(NSInteger)tag title:(NSString *)title icon:(NSImage *)icon {

	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
	item.tag = tag;
	item.image = icon;

	return item;
}

-(NSString *)userDefaultsKeyForPopup:(NSPopUpButton *)popup {

	if (popup == self.macAwokePopup)
		return kOnMacAwokeUserDefaultsKey;

	if (popup == self.macSleptPopup)
		return kOnMacSleptUserDefaultsKey;

	if (popup == self.tvSwitchedOffPopup)
		return kOnTVOffUserDefaultsKey;

	if (popup == self.tvSwitchedOnPopup)
		return kOnTVOnUserDefaultsKey;

	if (popup == self.lostActivePopup)
		return kOnTVLostActiveUserDefaultsKey;

	if (popup == self.becameActivePopup)
		return kOnTVBecameActiveUserDefaultsKey;

	return nil;
}

@end
