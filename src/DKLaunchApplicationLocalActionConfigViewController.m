//
//  DKLaunchApplicationLocalActionConfigViewController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKLaunchApplicationLocalActionConfigViewController.h"
#import "DKLaunchApplicationLocalAction.h"

@interface DKLaunchApplicationLocalActionConfigViewController ()

@end

@implementation DKLaunchApplicationLocalActionConfigViewController

-(id)init {
	return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+(NSSet *)keyPathsForValuesAffectingApplicationName {
	return [NSSet setWithObject:@"representedObject.bundleIdentifier"];
}

-(NSString *)applicationName {
	DKLaunchApplicationLocalAction *action = self.representedObject;
	NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:action.bundleIdentifier];
	if (path.length == 0) return action.bundleIdentifier;
	NSBundle *appBundle = [[NSBundle alloc] initWithPath:path];
	NSString *bundleName = [[appBundle infoDictionary] valueForKey:(__bridge NSString *)kCFBundleNameKey];
	if (bundleName.length > 0)
		return bundleName;
	else
		return [[path lastPathComponent] stringByDeletingPathExtension];
}

+(NSSet *)keyPathsForValuesAffectingApplicationIcon {
	return [NSSet setWithObject:@"representedObject.bundleIdentifier"];
}

-(NSImage *)applicationIcon {

	DKLaunchApplicationLocalAction *action = self.representedObject;
	NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:action.bundleIdentifier];
	if (path.length == 0) return [NSImage imageNamed:NSImageNameApplicationIcon];
	return [[NSWorkspace sharedWorkspace] iconForFile:path];
}

-(IBAction)chooseApplication:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.delegate = self;
    openPanel.message = NSLocalizedString(@"please choose the application title", @"");
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = YES;

	[openPanel beginSheetModalForWindow:self.view.window
					  completionHandler:^(NSInteger result) {

						  if (result != NSFileHandlingPanelOKButton) return;

						  NSBundle *appBundle = [NSBundle bundleWithURL:openPanel.URL];
						  if (appBundle.bundleIdentifier.length > 0) {
							  DKLaunchApplicationLocalAction *action = self.representedObject;
							  action.bundleIdentifier = appBundle.bundleIdentifier;
							  [[DKCECKeyMappingController sharedController] saveMappings];
						  } else {
							  [[NSAlert alertWithMessageText:NSLocalizedString(@"invalid application chosen title", @"")
											   defaultButton:NSLocalizedString(@"ok button title", @"")
											 alternateButton:@""
												 otherButton:@""
								   informativeTextWithFormat:NSLocalizedString(@"invalid application chosen description", @"")]
							   runModal];
						  }
					  }];
}

-(BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {

    NSString *path = [url path];
    if ([[path pathExtension] compare:@"app" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    } else {
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        return isDir;
    }
    return NO;
}

-(BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {

	NSString *path = [url path];
    if ([[path pathExtension] compare:@"app" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    } else {
		if (outError != NULL)
			*outError = [NSError errorWithDomain:@"error"
											code:0
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"invalid application chosen title", @""), NSLocalizedDescriptionKey,
												  NSLocalizedString(@"invalid application chosen description", @""), NSLocalizedRecoverySuggestionErrorKey,
												  nil]];
		
		return NO;
	}
}


@end
