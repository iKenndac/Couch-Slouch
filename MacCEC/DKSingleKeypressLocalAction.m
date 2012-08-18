//
//  DKSingleKeypressLocalAction.m
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKSingleKeypressLocalAction.h"

static NSString * const kDeviceKeyCodeKey = @"deviceCode";
static NSString * const kLocalKeyCodeKey = @"keyboardCode";

@interface DKSingleKeypressLocalAction ()

@property (nonatomic, readwrite) cec_user_control_code deviceKeyCode;
@property (nonatomic, readwrite) CGKeyCode localKeyCode;

@end

@implementation DKSingleKeypressLocalAction

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super init];

	if (self) {
		self.deviceKeyCode = [[plist valueForKey:kDeviceKeyCodeKey] integerValue];
		self.localKeyCode = [[plist valueForKey:kLocalKeyCodeKey] integerValue];
	}
	return self;
}

-(id)initWithLocalKeyCode:(CGKeyCode)keyCode forDeviceKeyCode:(cec_user_control_code)deviceCode {
	self = [super init];

	if (self) {
		self.deviceKeyCode = deviceCode;
		self.localKeyCode = keyCode;
	}
	return self;

}

-(id)propertyListRepresentation {
	return @{ kDeviceKeyCodeKey : @(self.deviceKeyCode), kLocalKeyCodeKey : @(self.localKeyCode) };
}

-(void)performActionWithKeyPress:(cec_keypress)keyPress {
	CGEventRef down = CGEventCreateKeyboardEvent(NULL, self.localKeyCode, true);
	CGEventRef up = CGEventCreateKeyboardEvent(NULL, self.localKeyCode, false);

	CGEventPost(kCGHIDEventTap, down);
	CGEventPost(kCGHIDEventTap, up);

	CFRelease(down);
	CFRelease(up);
	// TODO: Take keyboard layouts into account. Shortcut Recorder has sample code.
}

-(BOOL)matchesKeyPress:(cec_keypress)keyPress {
	return keyPress.keycode == self.deviceKeyCode;
}

@end
