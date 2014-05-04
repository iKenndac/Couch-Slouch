//
//  DKMenuButton.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 04/05/14.
//  For license information, see LICENSE.markdown
//

#import "DKMenuButton.h"

@implementation DKMenuButton

-(void)mouseDown:(NSEvent *)theEvent {

    // if a menu is defined let the cell handle its display
    if (self.menu) {
        if ([theEvent type] == NSLeftMouseDown) {
            [[self cell] setMenu:[self menu]];
        } else {
            [[self cell] setMenu:nil];
        }
    }

    [super mouseDown:theEvent];
}

@end
