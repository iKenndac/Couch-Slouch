//
//  DKAppDelegate.h
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKCECController.h"

@interface DKAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong, readwrite) DKCECController *controller;

@end
