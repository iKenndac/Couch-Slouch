//
//  DKCECWindowController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>
#import "cectypes.h"
#import "DKHDMIAddressSetupWindowController.h"

@interface DKCECWindowController : NSWindowController <DKHDMIAddressSetupWindowControllerDelegate>

@property (nonatomic, strong, readwrite) NSViewController *currentViewController;

@property (weak) IBOutlet NSToolbarItem *keybindsToolbarItem;
@property (weak) IBOutlet NSToolbarItem *behavioursToolbarItem;
@property (weak) IBOutlet NSToolbarItem *setupToolbarItem;
@property (weak) IBOutlet NSToolbarItem *compassToolbarItem;

- (IBAction)switchToKeybindsView:(id)sender;
- (IBAction)switchToBehavioursView:(id)sender;
- (IBAction)switchToSetupView:(id)sender;
- (IBAction)switchToCompassView:(id)sender;

-(BOOL)shouldConsumeKeypresses;
-(void)handleKeypress:(cec_keypress)press;

-(void)showHDMIConfigSheet:(BOOL)canCancel;

@end
