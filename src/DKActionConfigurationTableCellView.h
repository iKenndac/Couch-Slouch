//
//  DKActionConfigurationTableCellView.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DKActionConfigurationTableCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *typeMenu;
@property (weak) IBOutlet NSView *actionConfigContainer;

-(IBAction)typeMenuDidChange:(id)sender;

@end
