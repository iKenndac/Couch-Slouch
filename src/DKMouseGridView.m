//
//  DKMouseGridView.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2012.
//  For license information, see LICENSE.markdown
//

#import "DKMouseGridView.h"

@interface DKMouseGridView ()

@property (readwrite, nonatomic) CGFloat xStep;
@property (readwrite, nonatomic) CGFloat yStep;

@end

@implementation DKMouseGridView

-(BOOL)isFlipped {
	return YES;
}

-(void)setDrawBorder:(BOOL)drawBorder {
	_drawBorder = drawBorder;
	[self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	CGRect bounds = self.bounds;
	self.xStep = floor(bounds.size.width / 3.0);
	self.yStep = floor(bounds.size.height / 3.0);

	NSShadow *shadow = [NSShadow new];
	shadow.shadowBlurRadius = 4.0;
	shadow.shadowColor = [NSColor whiteColor];
	shadow.shadowOffset = NSZeroSize;
	[shadow set];

	NSBezierPath *path = [NSBezierPath new];
	path.lineWidth = 3.0;

	[path moveToPoint:NSMakePoint(CGRectGetMinX(bounds), self.yStep + .5)];
	[path lineToPoint:NSMakePoint(CGRectGetMaxX(bounds), self.yStep + .5)];

	[path moveToPoint:NSMakePoint(CGRectGetMinX(bounds), (self.yStep * 2) + .5)];
	[path lineToPoint:NSMakePoint(CGRectGetMaxX(bounds), (self.yStep * 2) + .5)];

	[path moveToPoint:NSMakePoint(self.xStep + .5, CGRectGetMinY(bounds))];
	[path lineToPoint:NSMakePoint(self.xStep + .5, CGRectGetMaxY(bounds))];

	[path moveToPoint:NSMakePoint((self.xStep * 2) + .5, CGRectGetMinY(bounds))];
	[path lineToPoint:NSMakePoint((self.xStep * 2) + .5, CGRectGetMaxY(bounds))];

	if (self.drawBorder)
		[path appendBezierPathWithRect:NSInsetRect(bounds, 1.5, 1.5)];

	[path stroke];

	CGFloat textSize = 70.0;
	if (self.yStep < textSize * 2)
		textSize = self.yStep / 2.0;
	textSize = MAX(12.0, textSize);

	NSDictionary *attributes = [self textAttributesWithSize:textSize];

	for (int rowIndex = 0; rowIndex < 3; rowIndex++) {
		for (int columnIndex = 0; columnIndex < 3; columnIndex++) {

			NSUInteger cellNumber = (rowIndex * 3) + columnIndex;
			NSRect cellRect = [self rectForSegment:cellNumber];

			NSString *numberString = [@(cellNumber + 1) stringValue];
			NSSize textSize = [numberString sizeWithAttributes:attributes];

			NSRect textRect = NSMakeRect(cellRect.origin.x,
										 NSMidY(cellRect) - (textSize.height / 2),
										 cellRect.size.width,
										 textSize.height);

			[numberString drawInRect:textRect withAttributes:attributes];

		}
	}
}

-(NSRect)rectForSegment:(NSUInteger)segmentIndex {
	NSUInteger row = segmentIndex / 3;
	NSUInteger column = segmentIndex % 3;

	return NSMakeRect(self.xStep * column, self.yStep * row, self.xStep, self.yStep);
}

-(NSDictionary *)textAttributesWithSize:(CGFloat)fontSize {

	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	style.alignment = NSCenterTextAlignment;

	return @{ NSFontAttributeName : [NSFont boldSystemFontOfSize:fontSize],
	NSParagraphStyleAttributeName : style };
}


@end
