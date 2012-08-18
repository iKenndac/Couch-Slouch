//
//  DKAppDelegate.h
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKCECDeviceController.h"
#import "DKCECWindowController.h"

@interface DKAppDelegate : NSObject <NSApplicationDelegate, DKCECDeviceControllerDelegate>

@property (nonatomic, strong, readwrite) DKCECDeviceController *cecController;
@property (nonatomic, strong, readwrite) DKCECWindowController *windowController;

@end
