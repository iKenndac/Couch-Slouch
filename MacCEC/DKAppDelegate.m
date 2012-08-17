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
	self.controller = [DKCECController new];
	self.controller.delegate = self;
}

-(void)cecController:(DKCECController *)controller didLogMessage:(NSString *)message ofSeverity:(cec_log_level)logLevel {
	NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), message);
}

@end
