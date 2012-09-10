//
//  DKSetupViewController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKCECWindowController.h"

@interface DKSetupViewController : NSViewController

@property (readwrite, weak) DKCECWindowController *windowController;

@end
