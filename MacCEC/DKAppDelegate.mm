//
//  DKAppDelegate.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKAppDelegate.h"
#import "cecc.h"

@implementation DKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	CEC::libcec_configuration config;
	memset(&config, 0, sizeof(config));
	
	int retCode = cec_initialise(&config);
	if (retCode == 0)
		NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"CEC init failed");
	
	const char * info = cec_get_lib_info();
	if (info != NULL)
		NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [NSString stringWithUTF8String:info]);
}

@end
