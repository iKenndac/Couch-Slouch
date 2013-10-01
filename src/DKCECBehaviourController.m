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

#pragma mark - Error Handing

-(void)handleScriptAtURL:(NSURL *)scriptURL didntHandleFunctionError:(NSString *)function {

	[self postErrorNotificationWithInformativeText:
	 [NSString stringWithFormat:NSLocalizedString(@"function not handled notification description", @""), function]];

	[self logErrorWithScriptURL:scriptURL
						 reason:[NSString stringWithFormat:NSLocalizedString(@"script error log script didnt handle function title", @""), function]
					   moreInfo:nil];
}

-(void)handleNoScriptError:(NSURL *)missingScriptLocation {

	[self postErrorNotificationWithInformativeText:NSLocalizedString(@"missing script notification description", @"")];

	[self logErrorWithScriptURL:missingScriptLocation
						 reason:[NSString stringWithFormat:NSLocalizedString(@"script error log script missing title", @"")]
					   moreInfo:nil];
}

-(void)handleScriptAtURL:(NSURL *)scriptURL threwError:(NSDictionary *)dict {

	NSString *message = dict[NSAppleScriptErrorBriefMessage];
	if (message.length == 0)
		message = dict[NSAppleScriptErrorMessage];

	[self postErrorNotificationWithInformativeText:
	 [NSString stringWithFormat:NSLocalizedString(@"script threw error notification description", @""), message, dict[NSAppleScriptErrorNumber]]];

	[self logErrorWithScriptURL:scriptURL
						 reason:[NSString stringWithFormat:NSLocalizedString(@"script error log script threw error title", @""), dict[NSAppleScriptErrorNumber], message]
					   moreInfo:dict];

}

-(void)postErrorNotificationWithInformativeText:(NSString *)text {

	if (![[NSUserDefaults standardUserDefaults] boolForKey:kShowScriptErrorsInNotificationCenterUserDefaultsKey])
		return;

	NSUserNotification *notification = [NSUserNotification new];
	notification.title = NSLocalizedString(@"script error notification title", @"");
	notification.informativeText = text;
	notification.actionButtonTitle = NSLocalizedString(@"script error notification button title", @"");

	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

}

-(void)logErrorWithScriptURL:(NSURL *)scriptURL reason:(NSString *)reason moreInfo:(id)moreInfo {

	NSMutableString *logToWrite = [NSMutableString new];

	[logToWrite appendFormat:NSLocalizedString(@"script error log date line", @""), [NSDate new]];
	[logToWrite appendString:@"\n"];
	[logToWrite appendFormat:NSLocalizedString(@"script error log location line", @""), [scriptURL path]];
	[logToWrite appendString:@"\n"];
	[logToWrite appendFormat:NSLocalizedString(@"script error log reason line", @""), reason];
	[logToWrite appendString:@"\n"];
	[logToWrite appendFormat:NSLocalizedString(@"script error log more info line", @""), moreInfo ? moreInfo : NSLocalizedString(@"script error log none title", @"")];
	[logToWrite appendString:@"\n"];
	[logToWrite appendString:@"\n====================================\n"];
	[logToWrite appendString:@"\n"];

	NSData *dataToWrite = [logToWrite dataUsingEncoding:NSUTF8StringEncoding];

	NSURL *userPath = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
															  inDomains:NSUserDomainMask] objectAtIndex:0];

	userPath = [userPath URLByAppendingPathComponent:kApplicationSupportFolderName isDirectory:YES];

	if (![userPath checkResourceIsReachableAndReturnError:nil])
		[[NSFileManager defaultManager] createDirectoryAtURL:userPath withIntermediateDirectories:YES attributes:nil error:nil];

	userPath = [userPath URLByAppendingPathComponent:kScriptLogFileName isDirectory:NO];

	if (![userPath checkResourceIsReachableAndReturnError:nil])
		[[NSFileManager defaultManager] createFileAtPath:[userPath path] contents:nil attributes:nil];

	NSFileHandle *output = [NSFileHandle fileHandleForWritingToURL:userPath error:nil];
	[output seekToEndOfFile];
	[output writeData:dataToWrite];
	[output closeFile];

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
	[self.device activateSource:^(BOOL success) {
		if (!success) NSLog(@"Power on not successful!");
	}];
}

-(void)turnOffTV {
	[self.device sendPowerOffToDevice:CECDEVICE_TV completion:^(BOOL success) {
		if (!success) NSLog(@"Power off not successful!");
	}];
}

-(void)runScriptWithFunction:(NSString *)function scriptUserDefaultsKey:(NSString *)userDefaultsKey  {

	NSURL *scriptURL = nil;

	NSString *storedScriptPath = [[NSUserDefaults standardUserDefaults] stringForKey:userDefaultsKey];
	if (storedScriptPath.length > 0)
		scriptURL = [NSURL URLWithString:storedScriptPath];

	if (scriptURL == nil || ![scriptURL checkResourceIsReachableAndReturnError:nil]) {
		[self handleNoScriptError:scriptURL];
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

		if (errorDictionary != nil) {

			NSInteger errorCode = [errorDictionary[NSAppleScriptErrorNumber] integerValue];
			if (errorCode == errAEEventNotHandled) {
				dispatch_async(dispatch_get_main_queue(), ^{ [self handleScriptAtURL:scriptURL didntHandleFunctionError:functionName]; });
				return;
			}

			dispatch_async(dispatch_get_main_queue(), ^{ [self handleScriptAtURL:scriptURL threwError:errorDictionary]; });
			
		}
	}];

}


@end
