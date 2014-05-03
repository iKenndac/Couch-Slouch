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
#import "DKCECDeviceController+SoftReset.h"

#include <mach/mach_port.h>
#include <mach/mach_interface.h>
#include <mach/mach_init.h>

#include <IOKit/pwr_mgt/IOPMLib.h>
#include <IOKit/IOMessage.h>

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
@property (readwrite) BOOL isWaitingForWakeAction;
@property (readwrite) io_connect_t powerPort;
@property (readwrite) BOOL skipExitBehaviours;

@end

@implementation DKAppDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {

	if ([[[NSProcessInfo processInfo] arguments] containsObject:kApplicationLaunchedAtStartupParameter])
		self.isWaitingForStartupAction = YES;

	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
	
	self.cecController = [DKCECDeviceController new];
	self.cecController.delegate = self;
	[DKCECBehaviourController sharedInstance].device = self.cecController;

	[self.cecController open:^(BOOL success) {
		if (!self.cecController.hasConnection) {

			/* 
			 Not having a connection at this point is often fine, however, either the
			 CEC adapter or Mac OS X or *something* has a bug that causes the
			 serial port service on the adapter to not be recognised if it's plugged
			 in while the system boots. This can be fixed by finding the device on the
			 USB bus directly and soft-resetting it.
			 */

			BOOL didReset = [self.cecController softResetCECAdapter];
			if (didReset)
				[self logMessageToDisk:@"A CEC adapter was found in limbo and reset." ofSeverity:CEC_LOG_WARNING];

			// Once you call open on DKCECDeviceController, it carries on
			// looking for devices so no further action is needed.
		}
	}];

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

    IONotificationPortRef notifyPortRef;
    io_object_t notifierObject;
    self.powerPort = IORegisterForSystemPower((__bridge void *)self, &notifyPortRef, PowerNotificationCallBack, &notifierObject);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(notifyPortRef), kCFRunLoopCommonModes);

	self.updater = [SUUpdater sharedUpdater];
	self.updater.delegate = self;
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

	self.skipExitBehaviours = YES;
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
			[self systemDidStartUp];
		}
        
        if (self.cecController.hasConnection && self.isWaitingForWakeAction) {
            self.isWaitingForWakeAction = NO;
            [[DKCECBehaviourController sharedInstance] handleMacAwake];
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

-(void)updaterWillRelaunchApplication:(SUUpdater *)updater {
	self.skipExitBehaviours = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:kDKPrepareForApplicationTerminationNotification object:nil];
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
	[self systemWillSleep:nil];
}

-(void)handleSimulatedWake {
	[self systemDidAwake];
}

void PowerNotificationCallBack(void *refCon, io_service_t service, natural_t messageType, void * messageArgument) {

	DKAppDelegate *self = (__bridge DKAppDelegate *)refCon;

    switch (messageType)  {

        case kIOMessageCanSystemSleep:
            /* Idle sleep is about to kick in. This message will not be sent for forced sleep.
			 Applications have a chance to prevent sleep by calling IOCancelPowerChange.
			 Most applications should not prevent idle sleep.

			 Power Management waits up to 30 seconds for you to either allow or deny idle
			 sleep. If you don't acknowledge this power change by calling either
			 IOAllowPowerChange or IOCancelPowerChange, the system will wait 30
			 seconds then go to sleep.
			 */

            //Uncomment to cancel idle sleep
            //IOCancelPowerChange( root_port, (long)messageArgument );
            // we will allow idle sleep
            IOAllowPowerChange(self.powerPort, (long)messageArgument );
            break;

        case kIOMessageSystemWillSleep: {
            /* The system WILL go to sleep. If you do not call IOAllowPowerChange or
			 IOCancelPowerChange to acknowledge this message, sleep will be
			 delayed by 30 seconds.

			 NOTE: If you call IOCancelPowerChange to deny sleep it returns
			 kIOReturnSuccess, however the system WILL still go to sleep.
			 */
			[self logMessageToDisk:@"Delaying system sleep for sleep behaviours…" ofSeverity:CEC_LOG_NOTICE];
			[self systemWillSleep:^{
				[self logMessageToDisk:@"Sleep behaviours done, allowing system sleep." ofSeverity:CEC_LOG_NOTICE];
				IOAllowPowerChange(self.powerPort, (long)messageArgument);
			}];

            break;

		}

        case kIOMessageSystemHasPoweredOn:
			[self systemDidAwake];
			break;

        default:
            break;

    }
}


-(void)systemDidStartUp {
	[[DKCECBehaviourController sharedInstance] handleMacStartup];
}

-(void)systemDidAwake {
    [self.cecController open:^(BOOL success) {
        [self logMessageToDisk:@"Reconnecting to CEC device after awake from sleep…" ofSeverity:CEC_LOG_NOTICE];
        
        if (self.cecController.hasConnection) {
            [[DKCECBehaviourController sharedInstance] handleMacAwake];
        } else {
            self.isWaitingForWakeAction = YES;
        }
        
    }];
}

-(void)systemWillSleep:(dispatch_block_t)block {
	[[DKCECBehaviourController sharedInstance] handleMacSleep:^{
		[self.cecController close:^(BOOL success) {
			[self logMessageToDisk:@"Closing connection to CEC device due to system sleep." ofSeverity:CEC_LOG_NOTICE];
			if (block) block();
		}];
	}];

}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

	if (self.skipExitBehaviours)
		return NSTerminateNow;

	[self.windowController close];

	[self logMessageToDisk:@"Delaying application exit for behaviours…" ofSeverity:CEC_LOG_NOTICE];
	[[DKCECBehaviourController sharedInstance] handleMacShutdown:^{
		[self logMessageToDisk:@"Exit behaviours done, allowing application exit." ofSeverity:CEC_LOG_NOTICE];
		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
	}];

	return NSTerminateLater;
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

	// First, resolve aliases.
	DKCECKeyMappingController *keyMapper = [DKCECKeyMappingController sharedController];
	keyPress.keycode = [keyMapper keyCodeByResolvingAliasesFromKeyCode:keyPress.keycode];

	if ([self.mouseGridController shouldConsumeKeypress:keyPress]) {
		[self.mouseGridController handleKeypress:keyPress];
		return;
	}

	if ([self.windowController shouldConsumeKeypresses]) {
		[self.windowController handleKeypress:keyPress];
		return;
	}

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

	static NSDateFormatter *logDateFormatter = nil;
	if (logDateFormatter == nil) {
		logDateFormatter = [NSDateFormatter new];
		logDateFormatter.dateStyle = NSDateFormatterShortStyle;
		logDateFormatter.timeStyle = NSDateFormatterShortStyle;
	}

	NSString *fullMessage = [NSString stringWithFormat:@"%@: (Log level %@): %@",
							 [logDateFormatter stringFromDate:[NSDate date]],
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

-(void)cecController:(DKCECDeviceController *)controller didReceiveCommand:(cec_command)command {

	if (command.initiator == CECDEVICE_TV) {

		if (command.opcode == CEC_OPCODE_PLAY) {
			// TV is telling us to play. Translate this into a PlayPause keypress.
			if (command.parameters.size == 1) {
				if (command.parameters.data[0] == CEC_PLAY_MODE_PLAY_FORWARD) {
					cec_keypress press;
					memset(&press, 0, sizeof(cec_keypress));
					press.keycode = CEC_USER_CONTROL_CODE_PLAY;
					[self handleSimulatedKeyPress:press];
				}
				if (command.parameters.data[0] == CEC_PLAY_MODE_PLAY_STILL) {
					cec_keypress press;
					memset(&press, 0, sizeof(cec_keypress));
					press.keycode = CEC_USER_CONTROL_CODE_PAUSE;
					[self handleSimulatedKeyPress:press];
				}
			}
		}

		if (command.opcode == CEC_OPCODE_DECK_CONTROL) {
			if (command.parameters.size == 1 &&
				command.parameters.data[0] == CEC_DECK_CONTROL_MODE_STOP) {
				// Send stop keypress
				cec_keypress press;
				memset(&press, 0, sizeof(cec_keypress));
				press.keycode = CEC_USER_CONTROL_CODE_STOP;
				[self handleSimulatedKeyPress:press];
			}
		}

	}

}

-(void)cecController:(DKCECDeviceController *)controller didReceiveAlert:(libcec_alert)alert forParamter:(libcec_parameter)parameter {}
-(void)cecController:(DKCECDeviceController *)controller activationDidChangeForLogicalDevice:(cec_logical_address)device toState:(BOOL)activated {}

@end
