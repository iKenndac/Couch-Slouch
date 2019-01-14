//
//  DKFancyDividerView.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 05/09/2012.
//  For license information, see LICENSE.markdown
//

#import "DKFancyDividerView.h"

@implementation DKFancyDividerView

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    CGFloat scale = self.window == nil ? 1.0 : self.window.backingScaleFactor;
    CGFloat lineHeight = 1.0 / scale;

    [[NSColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.0] set];

    NSBezierPath *path = [NSBezierPath new];
    path.lineWidth = lineHeight;
    [path moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 0.5)];
    [path lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 0.5)];
    [path stroke];
}

@end
