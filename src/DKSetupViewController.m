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

- (IBAction)showHDMIConfigSheet:(id)sender {
	[self.windowController showHDMIConfigSheet:YES];
}

@end
