//
//  main.m
//  Couch Slouch Login Helper
//
//  Created by Daniel Kennett on 30/09/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
	// This string takes you from MyGreat.App/Contents/Library/LoginItems/MyHelper.app to MyGreat.App This is an obnoxious but dynamic way to do this since that specific Subpath is required
	NSString *binaryPath = [[NSBundle bundleWithPath:appPath] executablePath]; // This gets the binary executable within your main application
	[[NSWorkspace sharedWorkspace] launchApplication:binaryPath];
	return 0;
}
