//
//  DKMouseGridWindowController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>
#import "cectypes.h"

@interface DKMouseGridWindowController : NSWindowController

-(BOOL)handleKeypress:(cec_keypress)press;
-(BOOL)shouldConsumeKeypresses;

-(void)showMouseGrid;

@end
