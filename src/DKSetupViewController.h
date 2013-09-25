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
@property (strong) IBOutlet NSWindow *preferencesWindow;
@property (strong) IBOutlet NSWindow *aboutWindow;
@property (unsafe_unretained) IBOutlet NSTextView *aboutCreditsView;
@property (weak) IBOutlet NSTextField *aboutVersionView;
@property (weak) IBOutlet NSTextField *aboutLibCECVersionView;

- (IBAction)showRemote:(id)sender;
- (IBAction)closePreferencesWindow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)closeAboutWindow:(id)sender;

@end
