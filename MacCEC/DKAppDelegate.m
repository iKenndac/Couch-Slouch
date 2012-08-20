//
//  DKAppDelegate.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKAppDelegate.h"
#import "DKCECKeyMappingController.h"
#import "DKSingleKeypressLocalAction.h"

@interface DKAppDelegate ()

@property (readwrite, nonatomic, copy) NSString *targetApplicationIdentifier;

@end

@implementation DKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.cecController = [DKCECDeviceController new];
	self.cecController.delegate = self;

	self.windowController = [DKCECWindowController new];
	
	for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
		if (app.active) {
			self.targetApplicationIdentifier = app.bundleIdentifier;
			break;
		}
	}

	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(applicationDidActivate:)
															   name:NSWorkspaceDidActivateApplicationNotification
															 object:nil];
}

-(BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication {
	[self.windowController showWindow:nil];
    return YES;
}

#pragma mark - Key Mapping

-(void)applicationDidActivate:(NSNotification *)notification {
	NSRunningApplication *app = [notification.userInfo valueForKey:NSWorkspaceApplicationKey];
	self.targetApplicationIdentifier = app.bundleIdentifier;
}

-(void)cecController:(DKCECDeviceController *)controller didReceiveKeyPress:(cec_keypress)keyPress {

	NSLog(@"Got keypress!");

	DKCECKeyMappingController *keyMapper = [DKCECKeyMappingController sharedController];
	DKCECKeyMapping *appMapping = [keyMapper keyMappingForApplicationWithIdentifier:self.targetApplicationIdentifier];
	id <DKLocalAction> action = [appMapping actionForKeyPress:keyPress];

	if (action != nil)
		[action performActionWithKeyPress:keyPress];
	else
		[[[keyMapper baseMapping] actionForKeyPress:keyPress] performActionWithKeyPress:keyPress];
}

-(void)cecController:(DKCECDeviceController *)controller didLogMessage:(NSString *)message ofSeverity:(cec_log_level)logLevel {
	NSLog(@"%@", message);
}

-(void)cecController:(DKCECDeviceController *)controller didReceiveCommand:(cec_command)command {}
-(void)cecController:(DKCECDeviceController *)controller didReceiveAlert:(libcec_alert)alert forParamter:(libcec_parameter)parameter {}
-(void)cecController:(DKCECDeviceController *)controller activationDidChangeForLogicalDevice:(cec_logical_address)device toState:(BOOL)activated {}


@end
