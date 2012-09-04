//
//  DKAppDelegate.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKAppDelegate.h"
#import "Constants.h"
#import "DKCECKeyMappingController.h"
#import "DKKeyboardShortcutLocalAction.h"
#import "DKLaunchApplicationLocalAction.h"
#import "DKDoNothingLocalAction.h"

@interface DKAppDelegate ()

@property (readwrite, nonatomic, copy) NSString *targetApplicationIdentifier;
@property (readwrite, nonatomic, copy) NSArray *waitingLogs;

@end

@implementation DKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.cecController = [DKCECDeviceController new];
	self.cecController.delegate = self;

	[DKKeyboardShortcutLocalAction class];
	[DKLaunchApplicationLocalAction class];
	[DKDoNothingLocalAction class];

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

	NSLog(@"Got keypress with duration: %@", @(keyPress.duration));
	if (keyPress.duration > 0)
		return;

	if ([self.windowController shouldConsumeKeypresses]) {
		[self.windowController handleKeypress:keyPress];
		return;
	}

	DKCECKeyMappingController *keyMapper = [DKCECKeyMappingController sharedController];
	DKCECKeyMapping *appMapping = [keyMapper keyMappingForApplicationWithIdentifier:self.targetApplicationIdentifier];
	id <DKLocalAction> action = [appMapping actionForKeyPress:keyPress];

	if (action != nil)
		[action performActionWithKeyPress:keyPress];
	else
		[[[keyMapper baseMapping] actionForKeyPress:keyPress] performActionWithKeyPress:keyPress];
}

#pragma mark -

-(void)cecController:(DKCECDeviceController *)controller didLogMessage:(NSString *)message ofSeverity:(cec_log_level)logLevel {
	if (logLevel <= CEC_LOG_WARNING) NSLog(@"%@", message);

	if ([[NSUserDefaults standardUserDefaults] boolForKey:kLogLibCECUserDefaultsKey]) {
		[self logMessageToDisk:message ofSeverity:logLevel];
	}
}

-(void)logMessageToDisk:(NSString *)msg ofSeverity:(cec_log_level)logLevel {

	NSString *fullMessage = [NSString stringWithFormat:@"%@: log_level: %@ : %@",
							 [NSDate date],
							 @(logLevel),
							 msg];

	if (self.waitingLogs == nil) self.waitingLogs = [NSArray array];
	self.waitingLogs = [self.waitingLogs arrayByAddingObject:fullMessage];

	[self performSelector:@selector(flushLog) withObject:nil afterDelay:5.0];
}

-(void)flushLog {

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];

	if (self.waitingLogs.count == 0)
		return;

	NSMutableData *dataToWrite = [NSMutableData data];
	NSArray *logsToWrite = self.waitingLogs;
	self.waitingLogs = [NSArray array];
	
	for (NSString *str in logsToWrite)
		[dataToWrite appendData:[[NSString stringWithFormat:@"%@\n", str] dataUsingEncoding:NSUTF8StringEncoding]];

	NSString *logFilePath = [@"~/Library/Logs/Couch Slouch.log" stringByExpandingTildeInPath];
	if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath])
		[[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
	
	NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
	[output seekToEndOfFile];
	[output writeData:dataToWrite];
	[output closeFile];

}

-(void)cecController:(DKCECDeviceController *)controller didReceiveCommand:(cec_command)command {}
-(void)cecController:(DKCECDeviceController *)controller didReceiveAlert:(libcec_alert)alert forParamter:(libcec_parameter)parameter {}
-(void)cecController:(DKCECDeviceController *)controller activationDidChangeForLogicalDevice:(cec_logical_address)device toState:(BOOL)activated {}


@end
