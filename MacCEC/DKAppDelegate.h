//
//  DKAppDelegate.h
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKCECController.h"
#import "DKCECWindowController.h"

@interface DKAppDelegate : NSObject <NSApplicationDelegate, DKCECControllerDelegate>

@property (nonatomic, strong, readwrite) DKCECController *cecController;
@property (nonatomic, strong, readwrite) DKCECWindowController *windowController;

@end
