//
//  DKActionConfigurationTableCellView.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>

@interface DKActionConfigurationTableCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *typeMenu;
@property (weak) IBOutlet NSView *actionConfigContainer;

-(IBAction)typeMenuDidChange:(id)sender;

@end
