//
//  DKButtonDecoratedTextField.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 05/09/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKButtonDecoratedTextField.h"

static CGFloat const kButtonTextPadding = 10.0;
static CGFloat const kButtonVerticalTextAdjustment = -1.0;

@interface DKButtonDecoratedTextField ()

@property (nonatomic, readwrite) NSRect buttonRect;
@property (nonatomic, readwrite) NSRect textRect;
@property (nonatomic, readwrite, strong) NSDictionary *cachedAttributes;

@end

@implementation DKButtonDecoratedTextField

-(void)setFrame:(NSRect)frameRect {
	NSRect oldFrame = self.frame;
	[super setFrame:frameRect];
	if (!NSEqualSizes(frameRect.size, oldFrame.size))
		[self recalculateLayout];
}

-(void)setObjectValue:(id<NSCopying>)obj {
	[super setObjectValue:obj];
	[self recalculateLayout];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	NSDrawThreePartImage(self.buttonRect,
						 [NSImage imageNamed:@"button-left"],
						 [NSImage imageNamed:@"button-centre"],
						 [NSImage imageNamed:@"button-right"],
						 NO,
						 NSCompositeSourceOver,
						 1.0,
						 self.isFlipped);

	[self.stringValue drawInRect:self.textRect
				  withAttributes:self.cachedAttributes];

}


-(void)recalculateLayout {

	self.cachedAttributes = nil;
	NSDictionary *attributes = [self textAttributes];
	NSImage *buttonImage = [NSImage imageNamed:@"button-left"];
	NSSize textSize = [self.stringValue sizeWithAttributes:attributes];

	NSRect buttonRect;
	buttonRect.size.height = buttonImage.size.height;
	buttonRect.origin.y = (self.bounds.size.height / 2) - (buttonRect.size.height / 2);
	buttonRect.size.width = textSize.width + (kButtonTextPadding * 2);

	switch (self.alignment) {
		case NSRightTextAlignment:
			buttonRect.origin.x = NSMinX(self.bounds);
			break;

		case NSCenterTextAlignment:
			buttonRect.origin.x = NSMidX(self.bounds) - (buttonRect.size.width / 2);
			break;

		case NSLeftTextAlignment:
		default:
			buttonRect.origin.x = NSMinX(self.bounds);
			break;
	}

	buttonRect = NSIntegralRect(buttonRect);
	buttonRect.size.height = 29.0;
	if ((int)buttonRect.size.width % 2 == 0)
		buttonRect.size.width++;

	NSRect textRect;
	textRect.size = textSize;
	textRect.origin.x = buttonRect.origin.x + kButtonTextPadding;
	textRect.origin.y = NSMidY(buttonRect) - (textSize.height / 2.0) + kButtonVerticalTextAdjustment;
	textRect = NSIntegralRect(textRect);
	
	self.buttonRect = buttonRect;
	self.textRect = textRect;
}


-(NSDictionary *)textAttributes {

	if (self.cachedAttributes != nil)
		return self.cachedAttributes;

	NSFont *font = [self font];

	NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
	[para setAlignment:NSCenterTextAlignment];
	NSColor *textColor = self.textColor;

	NSShadow *shadow = [NSShadow new];
	shadow.shadowBlurRadius = 1.0;
	shadow.shadowColor = [NSColor whiteColor];
	shadow.shadowOffset = NSMakeSize(0.0, -1.0);

	NSDictionary *attributes = @{ NSForegroundColorAttributeName : textColor,
				NSParagraphStyleAttributeName : para,
				NSFontAttributeName : font,
				NSShadowAttributeName : shadow };

	self.cachedAttributes = attributes;
	return attributes;
}

@end
