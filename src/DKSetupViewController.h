//
//  DKSetupViewController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKHDMIAddressSetupWindowController.h"

@interface DKSetupViewController : NSViewController <DKHDMIAddressSetupWindowControllerDelegate>

- (IBAction)showHDMIConfigSheet:(id)sender;

@end
