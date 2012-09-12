//
//  DKLaunchApplicationLocalActionConfigViewController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>

@interface DKLaunchApplicationLocalActionConfigViewController : NSViewController <NSOpenSavePanelDelegate>

@property (nonatomic, readonly, copy) NSString *applicationName;
@property (nonatomic, readonly, strong) NSImage *applicationIcon;

- (IBAction)chooseApplication:(id)sender;

@end
