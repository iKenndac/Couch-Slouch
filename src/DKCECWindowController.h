//
//  DKCECWindowController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "cectypes.h"

@interface DKCECWindowController : NSWindowController

@property (nonatomic, strong, readwrite) NSViewController *currentViewController;

@property (weak) IBOutlet NSToolbarItem *keybindsToolbarItem;
@property (weak) IBOutlet NSToolbarItem *behavioursToolbarItem;
@property (weak) IBOutlet NSToolbarItem *setupToolbarItem;

- (IBAction)switchToKeybindsView:(id)sender;
- (IBAction)switchToBehavioursView:(id)sender;
- (IBAction)switchToSetupView:(id)sender;

-(BOOL)shouldConsumeKeypresses;
-(void)handleKeypress:(cec_keypress)press;

@end
