//
//  DKCECWindowController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKCECWindowController.h"
#import "DKKeybindsViewController.h"
#import "DKSetupViewController.h"
#import "DKBehavioursViewController.h"
#import "DKAppDelegate.h"
#import "Constants.h"

@interface DKCECWindowController ()

@property (nonatomic, strong, readwrite) DKKeybindsViewController *keybindsViewController;
@property (nonatomic, strong, readwrite) DKBehavioursViewController *behaviourViewController;
@property (nonatomic, strong, readwrite) DKSetupViewController *setupViewController;
@property (nonatomic, strong, readwrite) DKHDMIAddressSetupWindowController *addressSetupController;

@end

@implementation DKCECWindowController

-(id)init {
	self = [super initWithWindowNibName:@"DKCECWindowController"];
	if (self) {
		self.keybindsViewController = [DKKeybindsViewController new];
		self.behaviourViewController = [DKBehavioursViewController new];
		self.setupViewController = [DKSetupViewController new];
		self.setupViewController.windowController = self;
		[self.window center];
	}
	return self;
}

-(void)awakeFromNib {
	[self.window setMovableByWindowBackground:YES];
	[self switchToSetupView:nil];

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasDoneFirstLaunchUserDefaultsKey]) {
		double delayInSeconds = 0.5;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			// Make sure we're frontmost when starting auto-setup
			[self.window setIsVisible:YES];
			[self.window orderFrontRegardless];
			[self showHDMIConfigSheet:NO];
		});
	}
}

-(BOOL)shouldConsumeKeypresses {
	return (self.currentViewController == self.keybindsViewController &&
			self.window.isMainWindow &&
			self.window.isKeyWindow &&
			self.window.isVisible &&
			[[NSApplication sharedApplication] isActive]);
}

-(void)handleKeypress:(cec_keypress)press {
	[self.keybindsViewController handleKeypress:press];
}

-(void)setCurrentViewController:(NSViewController *)aViewController {

    if (aViewController != self.currentViewController) {
        [self.currentViewController.view removeFromSuperview];
    }

    _currentViewController = aViewController;

    if (_currentViewController != nil) {
        _currentViewController.view.frame = [self.window.contentView bounds];
		[self.window.contentView addSubview:_currentViewController.view];

		NSView *contentView = self.window.contentView;
		[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|"
																			options:NSLayoutAttributeBaseline | NSLayoutFormatDirectionLeadingToTrailing
																			metrics:nil
																			  views:@{@"view": _currentViewController.view}]];

		[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
																			options:NSLayoutAttributeBaseline | NSLayoutFormatDirectionLeadingToTrailing
																			metrics:nil
																			  views:@{@"view": _currentViewController.view}]];
    }
}

- (IBAction)switchToKeybindsView:(id)sender {
	self.currentViewController = self.keybindsViewController;
	self.window.toolbar.selectedItemIdentifier = self.keybindsToolbarItem.itemIdentifier;
}

- (IBAction)switchToBehavioursView:(id)sender {
	self.currentViewController = self.behaviourViewController;
	self.window.toolbar.selectedItemIdentifier = self.behavioursToolbarItem.itemIdentifier;
}

- (IBAction)switchToSetupView:(id)sender {
	self.currentViewController = self.setupViewController;
	self.window.toolbar.selectedItemIdentifier = self.setupToolbarItem.itemIdentifier;
}

-(void)showHDMIConfigSheet:(BOOL)canCancel {
	if (self.addressSetupController == nil) self.addressSetupController = [DKHDMIAddressSetupWindowController new];
	self.addressSetupController.cancelEnabled = canCancel;
	self.addressSetupController.delegate = self;
	[self.addressSetupController reset];
	[NSApp beginSheet:self.addressSetupController.window modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

-(void)hdmiAddressSetup:(DKHDMIAddressSetupWindowController *)controller shouldCloseWithNewAddress:(NSNumber *)address {
	[NSApp endSheet:self.addressSetupController.window returnCode:0];
	[self.addressSetupController.window orderOut:self];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasDoneFirstLaunchUserDefaultsKey];
	
	if (address != nil)
		[((DKAppDelegate *)[NSApp delegate]).cecController updatePhysicalAddress:[address unsignedIntValue] completion:^(BOOL success) {}];
}

@end
