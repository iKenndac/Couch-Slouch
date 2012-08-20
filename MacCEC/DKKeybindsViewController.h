//
//  DKKeybindsViewController.h
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKCECKeyMappingController.h"

@interface DKKeybindsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSOpenSavePanelDelegate>

@property (nonatomic, readwrite, strong) DKCECKeyMapping *currentMapping;
@property (nonatomic, readwrite, strong) DKCECKeyMapping *chosenSourceMapping;
@property (nonatomic, readonly) NSArray *flattenedMappingList;

@property (weak) IBOutlet NSTableView *sourceList;
@property (strong) IBOutlet NSView *openPanelView;


-(IBAction)addApplication:(id)sender;

@end
