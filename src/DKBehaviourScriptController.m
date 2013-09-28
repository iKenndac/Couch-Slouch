//
//  DKBehaviourScriptController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2013.
//  For license information, see LICENSE.markdown
//

#import "DKBehaviourScriptController.h"
#import "Constants.h"

@interface DKBehaviourScriptController ()
@property (nonatomic, readwrite) NSArray *scripts;
@end

@implementation DKBehaviourScriptController {
	FSEventStreamRef eventStream;
	FSEventStreamContext *streamContext;
}

-(id)init {
	self = [super init];
	if (self) {
		[self addFSEvents];
		[self rebuildScripts];
	}
	return self;
}

-(void)dealloc {
	[self removeFSEvents];
}

-(void)openUserScriptsFolder {
	[self createUserSciptsDirectory];
	[[NSWorkspace sharedWorkspace] openURL:[self userScriptsDirectory]];
}

-(void)rebuildScripts {

	NSLog(@"Rebuilding scripts");

	NSMutableArray *newScripts = [NSMutableArray new];

	NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
															inDomains:NSUserDomainMask];

	for (NSURL *url in paths) {
		NSURL *path = url;
		path = [path URLByAppendingPathComponent:kApplicationSupportFolderName isDirectory:YES];
		path = [path URLByAppendingPathComponent:kScriptsFolderName isDirectory:YES];

		[newScripts addObjectsFromArray:[self scriptsInDirectory:path]];
	}

	self.scripts = newScripts;
}

-(NSArray *)scriptsInDirectory:(NSURL *)directory {
	return nil;
}

-(NSURL *)userScriptsDirectory {
	NSURL *userPath = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
															  inDomains:NSUserDomainMask] objectAtIndex:0];

	userPath = [userPath URLByAppendingPathComponent:kApplicationSupportFolderName isDirectory:YES];
	userPath = [userPath URLByAppendingPathComponent:kScriptsFolderName isDirectory:YES];

	return userPath;
}

-(void)createUserSciptsDirectory {

	NSURL *userPath = [self userScriptsDirectory];

	if (![userPath checkResourceIsReachableAndReturnError:nil])
		[[NSFileManager defaultManager] createDirectoryAtURL:userPath withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark - FSEvents

static void FSEventCallback(ConstFSEventStreamRef streamRef,
							void *clientCallBackInfo,
							size_t numEvents,
							void *eventPaths,
							const FSEventStreamEventFlags eventFlags[],
							const FSEventStreamEventId eventIds[]) {

	@autoreleasepool {
		// Be stupid - if something happened at all, rescan.
		DKBehaviourScriptController *self = (__bridge DKBehaviourScriptController *)clientCallBackInfo;
		[self rebuildScripts];
	}
}


-(void)addFSEvents {

	if (![[self userScriptsDirectory] checkResourceIsReachableAndReturnError:nil])
		[self createUserSciptsDirectory];

	NSArray *pathsToWatch = @[ [self userScriptsDirectory].path ];

	NSLog(@"[%@ %@]: Starting observer on %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), pathsToWatch);

	if (eventStream != NULL)
		[self removeFSEvents];

	if (streamContext == NULL) {
		streamContext = malloc(sizeof(struct FSEventStreamContext));
		streamContext->info = (__bridge void *)self;
		streamContext->release = (CFAllocatorReleaseCallBack)CFRelease;
		streamContext->retain = (CFAllocatorRetainCallBack)CFRetain;
		streamContext->copyDescription = (CFAllocatorCopyDescriptionCallBack)CFCopyDescription;
		streamContext->version = 0;
	}

	eventStream = FSEventStreamCreate(kCFAllocatorDefault,
									  FSEventCallback,
									  streamContext,
									  (__bridge CFArrayRef)pathsToWatch,
									  kFSEventStreamEventIdSinceNow,
									  2.0,
									  kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagIgnoreSelf | kFSEventStreamCreateFlagFileEvents);

	FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	FSEventStreamStart(eventStream);

}

-(void)removeFSEvents {

	if (eventStream == NULL) return;

	NSLog(@"[%@ %@]: Stopping Observer", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

	FSEventStreamStop(eventStream);
	FSEventStreamInvalidate(eventStream);
	FSEventStreamRelease(eventStream);
	eventStream = NULL;

}


@end
