//
//  DKMouseGridWindowController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2012.
//  For license information, see LICENSE.markdown
//

#import "DKMouseGridWindowController.h"
#import "DKMouseGridView.h"

static CGFloat const kMouseNudgeDistance = 10.0;
static CGFloat const kMinimumGridHeight = 16.0 * 3;
static NSTimeInterval kDoubleClickListenerBuffer = 0.5;

@interface DKMouseGridWindowController ()

@property (nonatomic, strong, readwrite) DKMouseGridView *gridView;
@property (nonatomic, readwrite) BOOL isWithinDoubleClickThreshold;
@property (nonatomic, readwrite) BOOL helpWindowHasBeenHidden;

@end

@implementation DKMouseGridWindowController

-(id)init {
	self = [super initWithWindowNibName:NSStringFromClass([self class])];

	if (self) {
		[self.window setFrame:[[NSScreen mainScreen] frame] display:NO];
		self.window.backgroundColor = [NSColor clearColor];
		self.window.hasShadow = NO;
		self.window.opaque = NO;
		self.window.level = CGShieldingWindowLevel();
		self.window.ignoresMouseEvents = YES;

		self.gridView = [[DKMouseGridView alloc] initWithFrame:[self.window.contentView bounds]];
		[self.window.contentView addSubview:self.gridView];

		self.helpWindow.level = CGShieldingWindowLevel();
		self.helpWindow.ignoresMouseEvents = YES;
	}
	return self;
}

-(void)showMouseGrid {
	[self showWindow:nil];

	NSRect centerRect = [self.gridView rectForSegment:4];
	NSRect helpWindowFrame = self.helpWindow.frame;
	helpWindowFrame.origin.y = NSMidY(centerRect) - (2 * NSHeight(helpWindowFrame));
	[self.helpWindow setFrame:helpWindowFrame display:NO];
	self.helpWindow.alphaValue = 1.0;
	self.helpWindowHasBeenHidden = NO;
	[self.helpWindow orderFront:self];
	
}

-(BOOL)shouldConsumeKeypress:(cec_keypress)press {
	if (self.window.isVisible)
		return YES;
	else
		return press.keycode == CEC_USER_CONTROL_CODE_SELECT && self.isWithinDoubleClickThreshold;
}

-(BOOL)handleKeypress:(cec_keypress)press {

	if (!self.helpWindowHasBeenHidden && self.helpWindow.isVisible) {
		self.helpWindowHasBeenHidden = YES;
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.helpWindow, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
		NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
		[animation startAnimation];
	}

	switch (press.keycode) {
		case CEC_USER_CONTROL_CODE_NUMBER1:
		case CEC_USER_CONTROL_CODE_NUMBER2:
		case CEC_USER_CONTROL_CODE_NUMBER3:
		case CEC_USER_CONTROL_CODE_NUMBER4:
		case CEC_USER_CONTROL_CODE_NUMBER5:
		case CEC_USER_CONTROL_CODE_NUMBER6:
		case CEC_USER_CONTROL_CODE_NUMBER7:
		case CEC_USER_CONTROL_CODE_NUMBER8:
		case CEC_USER_CONTROL_CODE_NUMBER9:
			[self handleNumberPress:press];
			return YES;
			break;

		case CEC_USER_CONTROL_CODE_EXIT:
			[self resetGrid];
			return YES;
			break;
			
		case CEC_USER_CONTROL_CODE_SELECT:
			[self clickMouse];
			if (!self.isWithinDoubleClickThreshold) {
				self.isWithinDoubleClickThreshold = YES;
				[self resetGrid];
				NSNumber *doubleClickTime = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain] valueForKey:@"com.apple.mouse.doubleClickThreshold"];
				int64_t delayInSeconds = MAX(doubleClickTime.doubleValue + kDoubleClickListenerBuffer, 1.0);
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					self.isWithinDoubleClickThreshold = NO;
				});
			}
			return YES;
			break;

		case CEC_USER_CONTROL_CODE_UP:
			[self nudgeMouseBy:NSMakeSize(0.0, -kMouseNudgeDistance)];
			return YES;
			break;

		case CEC_USER_CONTROL_CODE_DOWN:
			[self nudgeMouseBy:NSMakeSize(0.0, kMouseNudgeDistance)];
			return YES;
			break;

		case CEC_USER_CONTROL_CODE_LEFT:
			[self nudgeMouseBy:NSMakeSize(-kMouseNudgeDistance, 0.0)];
			return YES;
			break;

		case CEC_USER_CONTROL_CODE_RIGHT:
			[self nudgeMouseBy:NSMakeSize(kMouseNudgeDistance, 0.0)];
			return YES;
			break;

		default:
			break;
	}

	return NO;

}

-(void)clickMouse {

	CGEventRef getMousePositionEvent = CGEventCreate(NULL);
	CGPoint mousePoint = CGEventGetLocation(getMousePositionEvent);
	CFRelease(getMousePositionEvent);
	getMousePositionEvent = NULL;

	CGEventRef mouseDownEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, mousePoint, 0);
	CGEventRef mouseUpEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, mousePoint, 0);
	CGEventPost(kCGHIDEventTap, mouseDownEvent);
	CGEventPost(kCGHIDEventTap, mouseUpEvent);
	CFRelease(mouseDownEvent);
	CFRelease(mouseUpEvent);
	mouseDownEvent = NULL;
	mouseUpEvent = NULL;
}

-(void)nudgeMouseBy:(NSSize)mouseDelta {

	CGEventRef getMousePositionEvent = CGEventCreate(NULL);
	CGPoint mousePoint = CGEventGetLocation(getMousePositionEvent);
	CFRelease(getMousePositionEvent);
	getMousePositionEvent = NULL;

	mousePoint.x += mouseDelta.width;
	mousePoint.y += mouseDelta.height;

	[self moveMouseToPoint:mousePoint];
}

-(void)moveMouseToPoint:(CGPoint)mousePoint {
	CGEventRef mouseMoveEvent = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, mousePoint, 0);
	CGEventPost(kCGHIDEventTap, mouseMoveEvent);
	CFRelease(mouseMoveEvent);
	mouseMoveEvent = NULL;
}

-(void)handleNumberPress:(cec_keypress)press {

	NSUInteger segmentIndex = press.keycode - CEC_USER_CONTROL_CODE_NUMBER1;
	NSRect segmentFrame = [self.gridView rectForSegment:segmentIndex];
	NSRect newGridFrame = [self.window.contentView convertRect:segmentFrame fromView:self.gridView];
	NSPoint windowPoint = NSMakePoint(NSMidX(newGridFrame), NSHeight([self.window.contentView bounds]) - NSMidY(newGridFrame));
	[self moveMouseToPoint:NSPointToCGPoint(windowPoint)];

	if (segmentFrame.size.height < kMinimumGridHeight)
		// If the grid would be too small, return before resizing it
		return;

	self.gridView.frame = newGridFrame;
	self.gridView.drawBorder = YES;
}

-(void)resetGrid {
	self.gridView.frame = [self.window.contentView bounds];
	self.gridView.drawBorder = NO;

	[self.window close];
	[self.helpWindow close];
}

@end
