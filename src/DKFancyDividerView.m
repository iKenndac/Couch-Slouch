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

	[[[NSColor blackColor] colorWithAlphaComponent:0.1] set];

	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 0.5)
							  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 0.5)];

	[[NSColor whiteColor] set];

	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 1.5)
							  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 1.5)];


}

@end
