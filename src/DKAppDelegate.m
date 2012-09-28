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
#import "DKKeyboardShortcutLocalAction.h"
#import "DKLaunchApplicationLocalAction.h"
#import "DKDoNothingLocalAction.h"
#import <M3AppKit/M3AppKit.h>
#import <Sparkle/Sparkle.h>
#import "DKMouseGridWindowController.h"

static void * const kUpdateMenuBarItemContext = @"kUpdateMenuBarItemContext";

@interface DKAppDelegate ()

@property (readwrite, nonatomic, copy) NSString *targetApplicationIdentifier;
@property (readwrite, nonatomic, copy) NSArray *waitingLogs;
@property (readwrite, nonatomic, strong) NSStatusItem *statusBarItem;
@property (readwrite, nonatomic, strong) SUUpdater *updater;
@property (readwrite, nonatomic, strong) M3BetaController *betaController;
@property (readwrite, nonatomic, strong) DKMouseGridWindowController *mouseGridController;

@end

@implementation DKAppDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {

	self.betaController = [M3BetaController new];
	[self.betaController performBetaCheckWithDateString:[NSString stringWithUTF8String:__DATE__]];
	
	self.cecController = [DKCECDeviceController new];
	self.cecController.delegate = self;

	[DKKeyboardShortcutLocalAction class];
	[DKLaunchApplicationLocalAction class];
	[DKDoNothingLocalAction class];

	self.windowController = [DKCECWindowController new];
	self.mouseGridController = [DKMouseGridWindowController new];
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {

#if DEBUG
	self.remoteWindowController.delegate = self;
	[self.remoteWindowController showWindow:nil];
#endif

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
	
	[self addObserver:self forKeyPath:@"cecController.hasConnection" options:0 context:kUpdateMenuBarItemContext];
	[self addObserver:self forKeyPath:@"cecController.isActiveSource" options:NSKeyValueObservingOptionInitial context:kUpdateMenuBarItemContext];

	self.updater = [SUUpdater sharedUpdater];
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

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Key Mapping

-(void)applicationDidActivate:(NSNotification *)notification {
	NSRunningApplication *app = [notification.userInfo valueForKey:NSWorkspaceApplicationKey];
	self.targetApplicationIdentifier = app.bundleIdentifier;
}

-(void)handleSimulatedKeyPress:(cec_keypress)press {
	[self cecController:self.cecController didReceiveKeyPress:press];
}

-(void)cecController:(DKCECDeviceController *)controller didReceiveKeyPress:(cec_keypress)keyPress {

	NSLog(@"Got keypress with duration: %@", @(keyPress.duration));
	if (keyPress.duration > 0)
		return;

	if ([self.mouseGridController shouldConsumeKeypresses]) {
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
