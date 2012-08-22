//
//  DKSingleKeypressLocalAction.m
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKKeyboardShortcutLocalAction.h"
#import "SRKeyCodeTransformer.h"
#import "Constants.h"

static NSString * const kLocalKeyKey = @"keyboardKey";
static NSString * const kLocalFlagsKey = @"flags";

static SRKeyCodeTransformer *staticTransformer;

@interface DKKeyboardShortcutLocalAction ()

@property (nonatomic, readwrite) cec_user_control_code deviceKeyCode;
@property (nonatomic, readwrite, copy) NSString *localKey;
@property (nonatomic, readwrite) NSUInteger flags;

@end

@implementation DKKeyboardShortcutLocalAction

+(void)initialize {
	staticTransformer = [SRKeyCodeTransformer new];
}

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super init];

	if (self) {
		self.deviceKeyCode = [[plist valueForKey:kDeviceKeyCodeKey] integerValue];
		self.localKey = [plist valueForKey:kLocalKeyKey];
		self.flags = [[plist valueForKey:kLocalFlagsKey] unsignedIntegerValue];
	}
	return self;
}

-(id)initWithLocalKey:(NSString *)key flags:(NSUInteger)flags forDeviceKeyCode:(cec_user_control_code)deviceCode {
	self = [super init];

	if (self) {
		self.deviceKeyCode = deviceCode;
		self.localKey = key;
		self.flags = flags;
	}
	return self;

}

-(id)propertyListRepresentation {
	return @{ kDeviceKeyCodeKey : @(self.deviceKeyCode),
	kLocalKeyKey : self.localKey,
	kLocalFlagsKey : @(self.flags),
	kLocalActionPlistRepClassKey : NSStringFromClass(self.class)};
}

-(void)performActionWithKeyPress:(cec_keypress)keyPress {

	CGKeyCode theMainKey = (CGKeyCode)[[staticTransformer reverseTransformedValue:self.localKey] integerValue];
	CGEventFlags flags = 0;

	if (self.flags & NSCommandKeyMask)
		flags |= kCGEventFlagMaskCommand;
	
	if (self.flags & NSShiftKeyMask)
		flags |= kCGEventFlagMaskShift;
	
	if (self.flags & NSControlKeyMask)
		flags |= kCGEventFlagMaskControl;
	
	if (self.flags & NSAlternateKeyMask)
		flags |= kCGEventFlagMaskAlternate;

	CGEventRef down = CGEventCreateKeyboardEvent(NULL, theMainKey, true);
	CGEventSetFlags(down, flags);
	CGEventRef up = CGEventCreateKeyboardEvent(NULL, theMainKey, false);

	CGEventPost(kCGHIDEventTap, down);
	CGEventPost(kCGHIDEventTap, up);

	CFRelease(down);
	CFRelease(up);
}

-(BOOL)matchesKeyPress:(cec_keypress)keyPress {
	return keyPress.keycode == self.deviceKeyCode;
}

@end
