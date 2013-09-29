//
//  DKCECBehaviourController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 2013-09-25.
//  For license information, see LICENSE.markdown
//

#import "DKCECBehaviourController.h"
#import "Constants.h"
#import "SystemEvents.h"

@implementation DKCECBehaviourController

static DKCECBehaviourController *sharedInstance;

+(DKCECBehaviourController *)sharedInstance {
	if (sharedInstance == nil)
		sharedInstance = [DKCECBehaviourController new];
	return sharedInstance;
}

#pragma mark - TV Events

-(void)handleBecameActiveSource {
	[self handleTVEventWithUserDefaultsKey:kOnTVBecameActiveUserDefaultsKey
							scriptFunction:kAppleScriptBecameActiveFunctionName];
}

-(void)handleLostActiveSource {
	[self handleTVEventWithUserDefaultsKey:kOnTVLostActiveUserDefaultsKey
							scriptFunction:kAppleScriptLostActiveFunctionName];
}

-(void)handleTVSwitchedOn {
	[self handleTVEventWithUserDefaultsKey:kOnTVOnUserDefaultsKey
							scriptFunction:kAppleScriptTVOnFunctionName];
}

-(void)handleTVSwitchedOff {
	[self handleTVEventWithUserDefaultsKey:kOnTVOffUserDefaultsKey
							scriptFunction:kAppleScriptTVOffFunctionName];
}

#pragma mark - Mac Events

-(void)handleMacStartup {
	[self handleMacEventWithUserDefaultsKey:kOnMacAwokeUserDefaultsKey scriptFunction:kAppleScriptMacAwokeFunctionName];
}

-(void)handleMacAwake {
	[self handleMacEventWithUserDefaultsKey:kOnMacAwokeUserDefaultsKey scriptFunction:kAppleScriptMacAwokeFunctionName];
}

-(void)handleMacSleep {
	[self handleMacEventWithUserDefaultsKey:kOnMacSleptUserDefaultsKey scriptFunction:kAppleScriptMacSleptFunctionName];
}

-(void)handleMacShutdown {
	[self handleMacEventWithUserDefaultsKey:kOnMacSleptUserDefaultsKey scriptFunction:kAppleScriptMacSleptFunctionName];
}

#pragma mark - Helpers

-(void)handleTVEventWithUserDefaultsKey:(NSString *)userDefaultsKey scriptFunction:(NSString *)function {

	DKCECMacBehaviourAction action = [[NSUserDefaults standardUserDefaults] integerForKey:userDefaultsKey];

	if (action == DKCECBehaviourActionShutdownComputer) {
		[self shutdownComputer];
	} else if (action == DKCECBehaviourActionSleepComputer) {
		[self sleepComputer];
	} else if (action == DKCECBehaviourActionTriggerScript) {
		[self runScriptWithFunction:function scriptUserDefaultsKey:[userDefaultsKey stringByAppendingString:kOnActionScriptUserDefaultsKeySuffix]];
	}
}

-(void)handleMacEventWithUserDefaultsKey:(NSString *)userDefaultsKey scriptFunction:(NSString *)function {

	DKCECTVBehaviourAction action = [[NSUserDefaults standardUserDefaults] integerForKey:userDefaultsKey];

	if (action == DKCECTVBehaviourActionPowerOffTV) {
		[self turnOffTV];
	} else if (action == DKCECTVBehaviourActionPowerOnTV) {
		[self turnOnTV];
	} else if (action == DKCECTVBehaviourActionTriggerScript) {
		[self runScriptWithFunction:function scriptUserDefaultsKey:[userDefaultsKey stringByAppendingString:kOnActionScriptUserDefaultsKeySuffix]];
	}
}

-(void)sleepComputer {
	SystemEventsApplication *systemEvents = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
	[systemEvents sleep];
}

-(void)shutdownComputer {
	SystemEventsApplication *systemEvents = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
	[systemEvents shutDown];
}

-(void)turnOnTV {
	[self.device sendPowerOnToDevice:CECDEVICE_TV completion:^(BOOL success) {
		if (!success) NSLog(@"Power on not successful!");
	}];
}

-(void)turnOffTV {
	[self.device sendPowerOffToDevice:CECDEVICE_TV completion:^(BOOL success) {
		if (!success) NSLog(@"Power off not successful!");
	}];
}

-(void)handleNotHandledError {
	//TODO: Handle properly.
	NSLog(@"Function in script not handled!");
}

-(void)handleNoScriptError {
	//TODO: Handle properly.
	NSLog(@"Couldn't find script!");
}

-(void)handleScriptThrownError:(NSDictionary *)dict {
	//TODO: Handle properly.
	NSString *message = dict[NSAppleScriptErrorBriefMessage];
	if (message.length == 0)
		message = dict[NSAppleScriptErrorMessage];

	NSLog(@"Script failed with error code %@ and message: %@", dict[NSAppleScriptErrorNumber], message);

}

-(void)runScriptWithFunction:(NSString *)function scriptUserDefaultsKey:(NSString *)userDefaultsKey  {

	NSDictionary *errorDict = nil;
	NSURL *scriptURL = nil;

	NSString *storedScriptPath = [[NSUserDefaults standardUserDefaults] stringForKey:userDefaultsKey];
	if (storedScriptPath.length > 0)
		scriptURL = [NSURL URLWithString:storedScriptPath];

	if (scriptURL == nil || ![scriptURL checkResourceIsReachableAndReturnError:nil]) {
		[self handleNoScriptError];
		return;
	}

	if (![self executeScriptAtURL:scriptURL functionName:function error:&errorDict]) {


		NSInteger errorCode = [errorDict[NSAppleScriptErrorNumber] integerValue];
		if (errorCode == errAEEventNotHandled) {
			[self handleNotHandledError];
			return;
		}

		[self handleScriptThrownError:errorDict];

	}
}

-(BOOL)executeScriptAtURL:(NSURL *)scriptURL functionName:(NSString *)functionName error:(NSDictionary **)errorDict {

	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:errorDict];

	if (appleScript == nil)
		return NO;

	//Get a descriptor for ourself
	int pid = [[NSProcessInfo processInfo] processIdentifier];
	NSAppleEventDescriptor *thisApplication = [NSAppleEventDescriptor descriptorWithDescriptorType:typeKernelProcessID
																							 bytes:&pid
																							length:sizeof(pid)];

	//Create the container event
	//We need these constants from the Carbon OpenScripting framework, but we don't actually need Carbon.framework...
	#define kASAppleScriptSuite 'ascr'
	#define kASSubroutineEvent  'psbr'
	#define keyASSubroutineName 'snam'
	NSAppleEventDescriptor *containerEvent = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
																					  eventID:kASSubroutineEvent
																			 targetDescriptor:thisApplication
																					 returnID:kAutoGenerateReturnID
																				transactionID:kAnyTransactionID];

	//Set the target function
	[containerEvent setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:functionName]
							forKeyword:keyASSubroutineName];

	//Execute the event
	NSAppleEventDescriptor *result = [appleScript executeAppleEvent:containerEvent error:errorDict];
	if (result == nil)
		return NO;

	return YES;
}

@end
