//
//  DKAppDelegate.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKAppDelegate.h"

@implementation DKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.cecController = [DKCECDeviceController new];
	self.cecController.delegate = self;

	self.windowController = [DKCECWindowController new];

}

-(BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication {
	[self.windowController showWindow:nil];
    return YES;
}


@end
