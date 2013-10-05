//
//  DKSetupViewController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKSetupViewController.h"
#import "DKAppDelegate.h"
#import "Constants.h"

@implementation DKSetupViewController

-(id)init {
	return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

-(void)awakeFromNib {

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(prepareforExit:)
												 name:kDKPrepareForApplicationTerminationNotification
											   object:nil];
	
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];

	[self.aboutCreditsView setEditable:NO];
	[self.aboutCreditsView readRTFDFromFile:[myBundle pathForResource:@"Credits"
															   ofType:@"rtf"]];

	self.aboutVersionView.stringValue = [NSString stringWithFormat:NSLocalizedString(@"version formatter", @""),
										 [myBundle.infoDictionary valueForKey:@"CFBundleShortVersionString"],
										 [myBundle.infoDictionary valueForKey:@"CFBundleVersion"]];

	self.aboutLibCECVersionView.stringValue = [NSString stringWithFormat:NSLocalizedString(@"cec version formatter", @""),
											   [NSString stringWithFormat:@"%x", CEC_CLIENT_VERSION_CURRENT]];

}

- (IBAction)showHDMIConfigSheet:(id)sender {
	[self.windowController showHDMIConfigSheet:YES];
}

- (IBAction)showRemote:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationShouldShowVirtualRemoteNotificationName object:nil];
}

- (IBAction)closePreferencesWindow:(id)sender {
	if (![self.preferencesWindow isVisible])
		return;

	[NSApp endSheet:self.preferencesWindow];
	[self.preferencesWindow close];
}

- (IBAction)showPreferencesWindow:(id)sender {
	[NSApp beginSheet:self.preferencesWindow
	   modalForWindow:self.view.window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
}

- (IBAction)showAboutWindow:(id)sender {
	[NSApp beginSheet:self.aboutWindow
	   modalForWindow:self.view.window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
}

- (IBAction)closeAboutWindow:(id)sender {
	if (![self.aboutWindow isVisible])
		return;

	[NSApp endSheet:self.aboutWindow];
	[self.aboutWindow close];
}

-(void)prepareforExit:(NSNotification *)notification {
	[self closeAboutWindow:nil];
	[self closePreferencesWindow:nil];
}

@end
