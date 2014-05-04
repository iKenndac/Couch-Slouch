//
//  DKMenuButtonCell.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 04/05/14.
//  For license information, see LICENSE.markdown
//

#import "DKMenuButtonCell.h"

@implementation DKMenuButtonCell

-(BOOL)trackMouse:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
    // if menu defined show on left mouse
    if ([event type] == NSLeftMouseDown && [self menu]) {

        NSPoint result = [controlView convertPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame)) toView:nil];

        NSEvent *newEvent = [NSEvent mouseEventWithType:[event type]
                                               location:result
                                          modifierFlags:[event modifierFlags]
                                              timestamp:[event timestamp]
                                           windowNumber:[event windowNumber]
                                                context:[event context]
                                            eventNumber:[event eventNumber]
                                             clickCount:[event clickCount]
                                               pressure:[event pressure]];

        // need to generate a new event otherwise selection of button
        // after menu display fails
		[[self menu] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [NSMenu popUpContextMenu:[self menu] withEvent:newEvent forView:controlView];

        return YES;
    }

    return [super trackMouse:event inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}

@end
