//
//  DKActionConfigurationTableCellView.m
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKActionConfigurationTableCellView.h"
#import "DKLocalAction.h"
#import "Constants.h"

static void * kObjectChangedContext = @"kObjectChangedContext";

@interface DKActionConfigurationTableCellView ()

@property (nonatomic, readwrite, strong) NSViewController *currentViewController;

@end

@implementation DKActionConfigurationTableCellView

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self addObserver:self forKeyPath:@"objectValue" options:0 context:kObjectChangedContext];
	}

	return self;
}

-(void)dealloc {
	[self removeObserver:self forKeyPath:@"objectValue"];
}

-(void)awakeFromNib {
	[self rebuildMenu];
	[self updateMenuSelection];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kObjectChangedContext) {
        [self updateMenuSelection];
		[self typeMenuDidChange:self.typeMenu];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)rebuildMenu {
	NSMenu *newMenu = [NSMenu new];

	NSArray *actions = [DKLocalAction registeredConfigViewControllers];
	for (NSDictionary *action in actions) {
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[action valueForKey:kActionViewControllerDescriptionKey]
													  action:nil
											   keyEquivalent:@""];
		item.representedObject = action;
		[newMenu addItem:item];
	}

	self.typeMenu.menu = newMenu;
}

-(void)updateMenuSelection {

	for (NSMenuItem *item in self.typeMenu.menu.itemArray) {
		if ([item.representedObject valueForKey:kActionViewControllerActionClassKey] == [self.objectValue class]) {
			if (self.typeMenu.selectedItem != item) {
				[self.typeMenu selectItem:item];
				[self typeMenuDidChange:self.typeMenu];
			}
			break;
		}
	}
}

-(IBAction)typeMenuDidChange:(id)sender {
	
	if (self.currentViewController) {
		self.currentViewController.representedObject = nil;
		[self.currentViewController.view removeFromSuperview];
	}

	NSDictionary *actionInfo = self.typeMenu.selectedItem.representedObject;

	Class viewControllerClass = [actionInfo valueForKey:kActionViewControllerClassKey];
	if (viewControllerClass)
		self.currentViewController = [viewControllerClass new];
	else
		self.currentViewController = nil;

	// See if the given class matches our representedObject.
	Class actionClass = [actionInfo valueForKey:kActionViewControllerActionClassKey];
	if ([self.objectValue isKindOfClass:actionClass]) {
		self.currentViewController.representedObject = self.objectValue;
	} else {
		DKCECKeyMapping *mapping = [self.objectValue parentMapping];
		id <DKLocalAction> newAction = [[actionClass alloc] initWithDeviceKeyCode:[self.objectValue deviceKeyCode]];
		[mapping replaceAction:self.objectValue withAction:newAction];
		return;
	}

	if (self.currentViewController) {
		[self.actionConfigContainer addSubview:self.currentViewController.view];

		[self.actionConfigContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|"
																						   options:NSLayoutAttributeBaseline | NSLayoutFormatDirectionLeadingToTrailing
																						   metrics:nil
																							 views:@{@"view": self.currentViewController.view}]];

		[self.actionConfigContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
																						   options:NSLayoutAttributeBaseline | NSLayoutFormatDirectionLeadingToTrailing
																						   metrics:nil
																							 views:@{@"view": self.currentViewController.view}]];
	}
}

@end
