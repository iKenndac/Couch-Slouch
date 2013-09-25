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

-(void)handleBecameActiveSource {
	[self handleActionWithUserDefaultsKey:kOnTVBecameActiveUserDefaultsKey
						   scriptFunction:kAppleScriptBecameActiveFunctionName];
}

-(void)handleLostActiveSource {
	[self handleActionWithUserDefaultsKey:kOnTVLostActiveUserDefaultsKey
						   scriptFunction:kAppleScriptLostActiveFunctionName];
}

-(void)handleTVSwitchedOn {
	[self handleActionWithUserDefaultsKey:kOnTVOnUserDefaultsKey
						   scriptFunction:kAppleScriptTVOnFunctionName];
}

-(void)handleTVSwitchedOff {
	[self handleActionWithUserDefaultsKey:kOnTVOffUserDefaultsKey
						   scriptFunction:kAppleScriptTVOffFunctionName];
}

-(void)setScriptURL:(NSURL *)url {

	NSError *error = nil;

	NSData *bookmark = [url bookmarkDataWithOptions:0
					 includingResourceValuesForKeys:nil
									  relativeToURL:nil
											  error:&error];

	if (bookmark == nil || error) {
		NSLog(@"Got error when creating bookmark: %@", error);
		return;
	}

	[[NSUserDefaults standardUserDefaults] setObject:bookmark forKey:kOnTVActionScriptURL];

}

#pragma mark - Helpers

-(void)handleActionWithUserDefaultsKey:(NSString *)userDefaultsKey scriptFunction:(NSString *)function {

	DKCECBehaviourAction action = [[NSUserDefaults standardUserDefaults] integerForKey:userDefaultsKey];

	if (action == DKCECBehaviourActionShutdownComputer) {
		[self shutdownComputer];
	} else if (action == DKCECBehaviourActionSleepComputer) {
		[self sleepComputer];
	} else if (action == DKCECBehaviourActionTriggerScript) {
		[self runScriptWithFunction:function];
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

-(void)runScriptWithFunction:(NSString *)function {

	NSDictionary *errorDict = nil;
	NSURL *scriptURL = nil;

	NSData *bookmark = [[NSUserDefaults standardUserDefaults] dataForKey:kOnTVActionScriptURL];
	if (bookmark) {

		BOOL isStale = NO;
		NSError *error = nil;

		scriptURL = [NSURL URLByResolvingBookmarkData:bookmark
											  options:NSURLBookmarkResolutionWithoutUI | NSURLBookmarkResolutionWithoutMounting
										relativeToURL:nil
								  bookmarkDataIsStale:&isStale
												error:&error];

		if (error) {
			scriptURL = nil;
			NSLog(@"Saved bookmark got error: %@", error);
		}

		if (isStale && scriptURL)
			[self setScriptURL:scriptURL];
	}

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
