//
//  DKAppDelegate.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 16/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>
#import "DKCECDeviceController.h"
#import "DKCECWindowController.h"
#import "DKFakeRemoteWindowController.h"

@interface DKAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, DKCECDeviceControllerDelegate, DKFakeRemoteDelegate>

@property (nonatomic, strong, readwrite) DKCECDeviceController *cecController;
@property (nonatomic, strong, readwrite) DKCECWindowController *windowController;
@property (weak) IBOutlet NSMenu *statusBarMenu;
@property (unsafe_unretained) IBOutlet DKFakeRemoteWindowController *remoteWindowController;

- (IBAction)showMainWindow:(id)sender;
- (IBAction)quitFromMenu:(id)sender;


@end
