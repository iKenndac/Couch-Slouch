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

@interface DKMouseGridWindowController ()

@property (nonatomic, strong, readwrite) DKMouseGridView *gridView;

@end

@implementation DKMouseGridWindowController

-(id)init {
	self = [super init];

	if (self) {
		self.window = [[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame]
												  styleMask:NSBorderlessWindowMask
													backing:NSBackingStoreBuffered
													  defer:YES
													 screen:[NSScreen mainScreen]];

		self.window.backgroundColor = [NSColor clearColor];
		self.window.hasShadow = NO;
		self.window.opaque = NO;
		self.window.level = CGShieldingWindowLevel();
		self.window.ignoresMouseEvents = YES;

		self.gridView = [[DKMouseGridView alloc] initWithFrame:[self.window.contentView bounds]];
		[self.window.contentView addSubview:self.gridView];
	}
	return self;
}

-(void)showMouseGrid {
	[self showWindow:nil];
}

-(BOOL)shouldConsumeKeypresses {
	return self.window.isVisible;
}

-(BOOL)handleKeypress:(cec_keypress)press {

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
}

@end
