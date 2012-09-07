//
//  DKSetupViewController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKSetupViewController.h"
#import "DKHDMIAddressSetupWindowController.h"
#import "DKAppDelegate.h"

@interface DKSetupViewController ()

@property (nonatomic, readwrite, strong) DKHDMIAddressSetupWindowController *addressSetupController;

@end

@implementation DKSetupViewController

-(id)init {
	return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)showHDMIConfigSheet:(id)sender {
	if (self.addressSetupController == nil) self.addressSetupController = [DKHDMIAddressSetupWindowController new];
	self.addressSetupController.delegate = self;
	[self.addressSetupController reset];
	[NSApp beginSheet:self.addressSetupController.window modalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

-(void)hdmiAddressSetup:(DKHDMIAddressSetupWindowController *)controller shouldCloseWithNewAddress:(NSNumber *)address {
	[NSApp endSheet:self.addressSetupController.window returnCode:0];
	[self.addressSetupController.window orderOut:self];

	if (address != nil)
		[((DKAppDelegate *)[NSApp delegate]).cecController updatePhysicalAddress:[address unsignedIntValue] completion:^(BOOL success) {}];
}

@end
