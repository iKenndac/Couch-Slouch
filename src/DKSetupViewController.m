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
	
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];

	[self.aboutCreditsView setEditable:NO];
	[self.aboutCreditsView readRTFDFromFile:[myBundle pathForResource:@"Credits"
															   ofType:@"rtf"]];

	self.aboutVersionView.stringValue = [NSString stringWithFormat:NSLocalizedString(@"version formatter", @""),
										 [myBundle.infoDictionary valueForKey:@"CFBundleShortVersionString"],
										 [myBundle.infoDictionary valueForKey:@"CFBundleVersion"]];

}

- (IBAction)showHDMIConfigSheet:(id)sender {
	[self.windowController showHDMIConfigSheet:YES];
}

- (IBAction)showRemote:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationShouldShowVirtualRemoteNotificationName object:nil];
}

- (IBAction)closePreferencesWindow:(id)sender {
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
	[NSApp endSheet:self.aboutWindow];
	[self.aboutWindow close];
}

@end
