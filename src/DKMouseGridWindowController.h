//
//  DKMouseGridWindowController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>
#import "cectypes.h"

@class DKButtonDecoratedTextField;

@interface DKMouseGridWindowController : NSWindowController

@property (strong) IBOutlet NSPanel *helpWindow;
@property (strong) IBOutlet DKButtonDecoratedTextField *oneHelpbutton;
@property (strong) IBOutlet DKButtonDecoratedTextField *nineHelpbutton;

-(BOOL)handleKeypress:(cec_keypress)press;
-(BOOL)shouldConsumeKeypress:(cec_keypress)press;

-(void)showMouseGrid;

@end
