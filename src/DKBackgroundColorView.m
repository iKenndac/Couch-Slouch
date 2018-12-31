//
//  DKBackgroundColorView.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 2018-12-31.
//  Copyright © 2018 Daniel Kennett. All rights reserved.
//

#import "DKBackgroundColorView.h"

@implementation DKBackgroundColorView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.backgroundColor != nil) {
        [self.backgroundColor set];
        [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
    }
}

@end
