//
//  DKAppDelegate.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 16/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKAppDelegate.h"
#import "Constants.h"
#import "DKCECKeyMappingController.h"
#import "DKCECBehaviourController.h"
#import "DKKeyboardShortcutLocalAction.h"
#import "DKLaunchApplicationLocalAction.h"
#import "DKDoNothingLocalAction.h"
#import "DKShowMouseGridLocalAction.h"
#import <Sparkle/Sparkle.h>
#import "DKMouseGridWindowController.h"

static void * const kUpdateMenuBarItemContext = @"kUpdateMenuBarItemContext";
static void * const kTriggerStartupBehaviourOnConnectionContext = @"kTriggerStartupBehaviourOnConnectionContext";
static void * const kTriggerBehaviourOnTVEventContext = @"kTriggerBehaviourOnTVEventContext";

@interface DKAppDelegate ()

@property (readwrite, nonatomic, copy) NSString *targetApplicationIdentifier;
@property (readwrite, nonatomic, copy) NSArray *waitingLogs;
@property (readwrite, nonatomic, strong) NSStatusItem *statusBarItem;
@property (readwrite, nonatomic, strong) SUUpdater *updater;
@property (readwrite, nonatomic, strong) DKMouseGridWindowController *mouseGridController;
@property (readwrite) BOOL isWaitingForStartupAction;

@end

@implementation DKAppDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:kApplicationLaunchedAtStartupParameter])
		self.isWaitingForStartupAction = YES;

	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
	
	self.cecController = [DKCECDeviceController new];
	self.cecController.delegate = self;
	[DKCECBehaviourController sharedInstance].device = self.cecController;

	[DKKeyboardShortcutLocalAction class];
	[DKLaunchApplicationLocalAction class];
	[DKDoNothingLocalAction class];
	[DKShowMouseGridLocalAction class];

	self.windowController = [DKCECWindowController new];
	self.mouseGridController = [DKMouseGridWindowController new];
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	self.remoteWindowController.delegate = self;

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

	self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	self.statusBarItem.highlightMode = YES;
	self.statusBarItem.menu = self.statusBarMenu;
	
	[self addObserver:self forKeyPath:@"cecController.hasConnection" options:NSKeyValueObservingOptionInitial context:kUpdateMenuBarItemContext];
	[self addObserver:self forKeyPath:@"cecController.isActiveSource" options:NSKeyValueObservingOptionInitial context:kUpdateMenuBarItemContext];
	[self addObserver:self forKeyPath:@"cecController.hasConnection" options:NSKeyValueObservingOptionInitial context:kTriggerStartupBehaviourOnConnectionContext];

	[self addObserver:self
		   forKeyPath:@"cecController.isActiveSource"
			  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			   context:kTriggerBehaviourOnTVEventContext];

	[self addObserver:self
		   forKeyPath:@"cecController.isTVOn"
			  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			  context:kTriggerBehaviourOnTVEventContext];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showMouseGrid:)
												 name:kApplicationShouldShowMouseGridNotificationName
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showVirtualRemote:)
												 name:kApplicationShouldShowVirtualRemoteNotificationName
											   object:nil];

	NSNotificationCenter *workspaceCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	[workspaceCenter addObserver:self
						selector:@selector(workSpaceDidWake:)
							name:NSWorkspaceDidWakeNotification
						  object:nil];

	[workspaceCenter addObserver:self
						selector:@selector(workSpaceDidSleep:)
							name:NSWorkspaceWillSleepNotification
						  object:nil];

	[workspaceCenter addObserver:self
						selector:@selector(workspaceDidShutdown:)
							name:NSWorkspaceWillPowerOffNotification
						  object:nil];

	self.updater = [SUUpdater sharedUpdater];
}

-(void)showMouseGrid:(NSNotification *)notification {
	[self.mouseGridController showMouseGrid];
}

-(void)showVirtualRemote:(NSNotification *)notification {
	[self.remoteWindowController showWindow:nil];
}

-(BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication {
	[self.windowController showWindow:nil];
    return YES;
}

- (IBAction)showMainWindow:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
    [self.windowController.window setIsVisible:YES];
    [self.windowController.window orderFrontRegardless];
}

- (IBAction)quitFromMenu:(id)sender {

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kSkipQuitAlertUserDefaultsKey]) {
		NSAlert *alert = [NSAlert new];
		alert.messageText = NSLocalizedString(@"quit alert title", @"");
		alert.informativeText = NSLocalizedString(@"quit alert description", @"");
		[alert addButtonWithTitle:NSLocalizedString(@"quit button title", @"")];
		[alert addButtonWithTitle:NSLocalizedString(@"cancel button title", @"")];
		alert.showsSuppressionButton = YES;
		alert.suppressionButton.title = NSLocalizedString(@"quit alert suppress title", @"");

		if ([alert runModal] == NSAlertSecondButtonReturn)
			return;

		[[NSUserDefaults standardUserDefaults] setBool:(alert.suppressionButton.state == NSOnState)
												forKey:kSkipQuitAlertUserDefaultsKey];
	}

	[[NSApplication sharedApplication] terminate:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
    if (context == kUpdateMenuBarItemContext) {
		if (!self.cecController.hasConnection)
			self.statusBarItem.image = [NSImage imageNamed:@"menubar-noconnection"];
		else if (!self.cecController.isActiveSource)
			self.statusBarItem.image = [NSImage imageNamed:@"menubar-off"];
		else
			self.statusBarItem.image = [NSImage imageNamed:@"menubar-on"];

	} else if (context == kTriggerStartupBehaviourOnConnectionContext) {

		if (self.cecController.hasConnection && self.isWaitingForStartupAction) {
			self.isWaitingForStartupAction = NO;
			[self workspaceDidStartup];
		}

	} else if (context == kTriggerBehaviourOnTVEventContext) {

		id oldValue = change[NSKeyValueChangeOldKey];
		id newValue = change[NSKeyValueChangeNewKey];

		if (oldValue == [NSNull null] || newValue == [NSNull null])
			return;

		BOOL valueChanged = [oldValue boolValue] != [newValue boolValue];
		BOOL value = [newValue boolValue];

		if (!valueChanged) return;

		if ([keyPath isEqualToString:@"cecController.isActiveSource"]) {
			if (value)
				[[DKCECBehaviourController sharedInstance] handleBecameActiveSource];
			else
				[[DKCECBehaviourController sharedInstance] handleLostActiveSource];

		} else if ([keyPath isEqualToString:@"cecController.isTVOn"]) {
			if (value)
				[[DKCECBehaviourController sharedInstance] handleTVSwitchedOn];
			else
				[[DKCECBehaviourController sharedInstance] handleTVSwitchedOff];
		}

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
	return YES;
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {

	NSURL *userPath = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
															  inDomains:NSUserDomainMask] objectAtIndex:0];

	userPath = [userPath URLByAppendingPathComponent:kApplicationSupportFolderName isDirectory:YES];
	userPath = [userPath URLByAppendingPathComponent:kScriptLogFileName isDirectory:NO];
	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[userPath]];

}


#pragma mark - Behaviours

-(void)handleSimulatedOpCode:(cec_opcode)opcode {

	if (opcode == CEC_OPCODE_IMAGE_VIEW_ON)
		[[DKCECBehaviourController sharedInstance] handleTVSwitchedOn];

	if (opcode == CEC_OPCODE_STANDBY)
		[[DKCECBehaviourController sharedInstance] handleTVSwitchedOff];

	if (opcode == CEC_OPCODE_ACTIVE_SOURCE)
		[[DKCECBehaviourController sharedInstance] handleBecameActiveSource];

	if (opcode == CEC_OPCODE_INACTIVE_SOURCE)
		[[DKCECBehaviourController sharedInstance] handleLostActiveSource];

}

-(void)handleSimulatedSleep {
	[self workSpaceDidSleep:nil];
}

-(void)handleSimulatedWake {
	[self workSpaceDidWake:nil];
}

-(void)workSpaceDidWake:(NSNotification *)notification {
	[[DKCECBehaviourController sharedInstance] handleMacAwake];
}

-(void)workSpaceDidSleep:(NSNotification *)notification {
	[[DKCECBehaviourController sharedInstance] handleMacSleep];
}

-(void)workSpaceDidShutdown:(NSNotification *)notification {
	[[DKCECBehaviourController sharedInstance] handleMacShutdown];
}

-(void)workspaceDidStartup {
	[[DKCECBehaviourController sharedInstance] handleMacStartup];
}

#pragma mark - Key Mapping

-(void)applicationDidActivate:(NSNotification *)notification {
	NSRunningApplication *app = [notification.userInfo valueForKey:NSWorkspaceApplicationKey];
	self.targetApplicationIdentifier = app.bundleIdentifier;
}

-(void)handleSimulatedKeyPress:(cec_keypress)press {
	[self cecController:self.cecController didReceiveKeyDown:press];
}

-(void)cecController:(DKCECDeviceController *)controller didReceiveKeyDown:(cec_keypress)keyPress {

	if ([self.mouseGridController shouldConsumeKeypress:keyPress]) {
		[self.mouseGridController handleKeypress:keyPress];
		return;
	}

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

-(void)cecController:(DKCECDeviceController *)controller didReceiveKeyUp:(cec_keypress)keyPress {}

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
