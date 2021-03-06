//
//  DKScriptRunnerXPCController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 29/09/2013.
//  For license information, see LICENSE.markdown
//

#import "DKScriptRunnerXPCController.h"

@implementation DKScriptRunnerXPCController

-(BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	newConnection.exportedObject = self;
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DKCouchSlouchRunScript)];
	[newConnection resume];
	return YES;
}

-(void)runFunction:(NSString *)function
	 inScriptAtURL:(NSURL *)scriptURL
		  callback:(void (^)(NSURL *scriptURL, NSDictionary *errorDictionary))block {

	dispatch_async(dispatch_get_main_queue(), ^{

		NSDictionary *errorDict = nil;
		NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:&errorDict];

		if (appleScript == nil) {
			if (block) block(scriptURL, errorDict);
			return;
		}

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
		[containerEvent setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:function]
								forKeyword:keyASSubroutineName];

		//Execute the event
		NSAppleEventDescriptor *result = [appleScript executeAppleEvent:containerEvent error:&errorDict];
		if (result == nil) {

			NSMutableDictionary *xpcSafeDictionary = [NSMutableDictionary new];
			for (NSString *key in errorDict) {
				id value = errorDict[key];
				if (![self objectIsXPCSafe:value]) {
					xpcSafeDictionary[key] = [NSString stringWithFormat:@"%@", value];
				} else {
					xpcSafeDictionary[key] = value;
				}
			}

			if (block) block(scriptURL, xpcSafeDictionary);
			return;
		}

		if (block) block(scriptURL, nil);

	});

}

static NSArray *xpcSafeClasses;

-(BOOL)objectIsXPCSafe:(id)obj {

	if (xpcSafeClasses == nil)
		xpcSafeClasses = @[[NSNumber class], [NSArray class], [NSDictionary class], [NSString class], [NSDate class], [NSData class]];

	for (Class class in xpcSafeClasses) {
		if ([obj isKindOfClass:class])
			return YES;
	}

	return NO;
}

@end
