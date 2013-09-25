//
//  DKCECBehaviourController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 2013-09-25.
//  For license information, see LICENSE.markdown
//

#import "DKCECBehaviourController.h"
#import "Constants.h"

@implementation DKCECBehaviourController


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

-(void)sleepComputer {}

-(void)shutdownComputer {}

-(void)runScriptWithFunction:(NSString *)function {

	NSDictionary *errorDict = nil;
	NSURL *scriptURL = nil;

	if (![self executeScriptAtURL:scriptURL functionName:function error:&errorDict]) {
		NSLog(@"Script got error! %@", errorDict);
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
