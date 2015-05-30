//
//  NSApplication+AppleScriptAdditions.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 30/05/15.
//  Copyright (c) 2015 Daniel Kennett. All rights reserved.
//

#import "NSApplication+AppleScriptAdditions.h"
#import "DKAppDelegate.h"

@implementation NSApplication (AppleScriptAdditions)

-(DKCECDeviceController *)applescriptCecController {
    return [(DKAppDelegate *)self.delegate cecController];
}

-(BOOL)isActiveSource {
    return [[self applescriptCecController] isActiveSource];
}

-(BOOL)hasConnection {
    return [[self applescriptCecController] hasConnection];
}

-(BOOL)isTVOn {
    return [[self applescriptCecController] isTVOn];
}

@end
