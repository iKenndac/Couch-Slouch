//
//  DKAppDelegate.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKAppDelegate.h"
#import "DKCECController.h"

@implementation DKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.controller = [DKCECController new];
}

@end
