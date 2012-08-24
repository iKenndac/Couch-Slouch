//
//  DKLaunchApplicationLocalActionConfigViewController.h
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DKLaunchApplicationLocalActionConfigViewController : NSViewController <NSOpenSavePanelDelegate>

@property (nonatomic, readonly, copy) NSString *applicationName;
@property (nonatomic, readonly, strong) NSImage *applicationIcon;

- (IBAction)chooseApplication:(id)sender;

@end
