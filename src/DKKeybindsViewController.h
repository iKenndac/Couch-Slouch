//
//  DKKeybindsViewController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>
#import "DKCECKeyMappingController.h"
#import "SRRecorderControl.h"

@interface DKKeybindsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSOpenSavePanelDelegate>

@property (nonatomic, readwrite, strong) DKCECKeyMapping *currentMapping;
@property (nonatomic, readwrite, strong) DKCECKeyMapping *chosenSourceMapping;
@property (nonatomic, readonly) NSArray *flattenedMappingList;
@property (weak) IBOutlet SRRecorderControl *recorder;

@property (weak) IBOutlet NSTableView *sourceList;
@property (strong) IBOutlet NSView *openPanelView;
@property (weak) IBOutlet NSTableView *actionsList;


-(IBAction)addApplication:(id)sender;

-(void)handleKeypress:(cec_keypress)press;

@end
