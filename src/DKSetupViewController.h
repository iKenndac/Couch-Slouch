//
//  DKSetupViewController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>
#import "DKCECWindowController.h"

@interface DKSetupViewController : NSViewController

@property (readwrite, weak) DKCECWindowController *windowController;

@end
