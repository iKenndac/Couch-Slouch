//
//  DKCECWindowController.m
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKCECWindowController.h"
#import "DKKeybindsViewController.h"
#import "DKSetupViewController.h"
#import "DKBehavioursViewController.h"

@interface DKCECWindowController ()

@property (nonatomic, strong, readwrite) NSViewController *keybindsViewController;
@property (nonatomic, strong, readwrite) NSViewController *behaviourViewController;
@property (nonatomic, strong, readwrite) NSViewController *setupViewController;

@end

@implementation DKCECWindowController

-(id)init {
	self = [super initWithWindowNibName:@"DKCECWindowController"];
	if (self) {
		self.keybindsViewController = [DKKeybindsViewController new];
		self.behaviourViewController = [DKBehavioursViewController new];
		self.setupViewController = [DKSetupViewController new];
		[self.window center];
	}
	return self;
}

-(void)awakeFromNib {
	[self switchToKeybindsView:nil];
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

@end
