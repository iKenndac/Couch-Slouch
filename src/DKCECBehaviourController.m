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
#import "DKScriptRunnerXPCController.h"

@interface DKCECBehaviourController ()
@property (nonatomic, readwrite) NSXPCConnection *xpcConnection;
@property (nonatomic, readwrite) id <DKCouchSlouchRunScript> scriptProxy;
@end

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

-(void)handleNotHandledError:(NSString *)function {
	//TODO: Handle properly.
	NSLog(@"Function %@ () in script not handled!", function);
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

	NSURL *scriptURL = nil;

	NSString *storedScriptPath = [[NSUserDefaults standardUserDefaults] stringForKey:userDefaultsKey];
	if (storedScriptPath.length > 0)
		scriptURL = [NSURL URLWithString:storedScriptPath];

	if (scriptURL == nil || ![scriptURL checkResourceIsReachableAndReturnError:nil]) {
		[self handleNoScriptError];
		return;
	}

	[self executeScriptOverXPCAtURL:scriptURL functionName:function];

	return;

}

-(void)executeScriptOverXPCAtURL:(NSURL *)scriptURL functionName:(NSString *)functionName {

	if (self.xpcConnection == nil) {
		self.xpcConnection = [[NSXPCConnection alloc] initWithServiceName:kScriptRunnerXPCServiceName];
		self.xpcConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DKCouchSlouchRunScript)];
		[self.xpcConnection resume];

		self.scriptProxy = [self.xpcConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
			NSLog(@"Got error %@", error);
		}];
	}

	[self.scriptProxy runFunction:functionName inScriptAtURL:scriptURL callback:^(NSURL *scriptURL, NSDictionary *errorDictionary) {
		NSLog(@"Reply from run script is: %@", errorDictionary);
	}];

}


@end
