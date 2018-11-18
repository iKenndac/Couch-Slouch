//
//  DKCECDeviceController+AppleScript.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 30/05/15.
//  Copyright (c) 2015 Daniel Kennett. All rights reserved.
//

#import "DKCECDeviceController+AppleScript.h"
#import "NSApplication+AppleScriptAdditions.h"

@implementation DKCECDeviceController (AppleScript)

-(id)objectSpecifier {
    NSScriptObjectSpecifier *applicationSpecifier = [[NSApplication sharedApplication] objectSpecifier];
    return [[NSPropertySpecifier alloc] initWithContainerSpecifier:applicationSpecifier key:@"applescriptCecController"];
}

@end

@implementation DKCECDeviceControllerTurnOnTVCommand : NSScriptCommand

-(id)performDefaultImplementation {

    DKCECDeviceController *controller = [NSApplication sharedApplication].applescriptCecController;

    if (!controller.hasConnectionToDevice) {
        self.scriptErrorNumber = NSReceiversCantHandleCommandScriptError;
        self.scriptErrorString = @"Cannot perform CEC commands with no CEC device present.";
        return nil;
    }

    [controller sendPowerOnToDevice:CECDEVICE_TV completion:^(BOOL success) {
        if (!success) {
            self.scriptErrorNumber = NSReceiversCantHandleCommandScriptError;
            self.scriptErrorString = @"Unable to power on the TV.";
        }
        [self resumeExecutionWithResult:nil];
    }];

    [self suspendExecution];
    return nil;
}

@end

@implementation DKCECDeviceControllerTurnOffTVCommand : NSScriptCommand

-(id)performDefaultImplementation {

    DKCECDeviceController *controller = [NSApplication sharedApplication].applescriptCecController;

    if (!controller.hasConnectionToDevice) {
        self.scriptErrorNumber = NSReceiversCantHandleCommandScriptError;
        self.scriptErrorString = @"Cannot perform CEC commands with no CEC device present.";
        return nil;
    }

    [controller sendPowerOffToDevice:CECDEVICE_TV completion:^(BOOL success) {
        if (!success) {
            self.scriptErrorNumber = NSReceiversCantHandleCommandScriptError;
            self.scriptErrorString = @"Unable to power off the TV.";
        }
        [self resumeExecutionWithResult:nil];
    }];

    [self suspendExecution];
    return nil;
}

@end

@implementation DKCECDeviceControllerBecomeActiveSourceCommand : NSScriptCommand

-(id)performDefaultImplementation {

    DKCECDeviceController *controller = [NSApplication sharedApplication].applescriptCecController;

    if (!controller.hasConnectionToDevice) {
        self.scriptErrorNumber = NSReceiversCantHandleCommandScriptError;
        self.scriptErrorString = @"Cannot perform CEC commands with no CEC device present.";
        return nil;
    }

    [controller activateSource:^(BOOL success) {
        if (!success) {
            self.scriptErrorNumber = NSReceiversCantHandleCommandScriptError;
            self.scriptErrorString = @"Unable to become the active source.";
        }
        [self resumeExecutionWithResult:nil];
    }];

    [self suspendExecution];
    return nil;
}

@end
