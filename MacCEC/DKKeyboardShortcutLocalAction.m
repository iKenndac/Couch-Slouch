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
#import "DKKeyboardShortcutLocalActionConfigViewController.h"
#import "DKCECDeviceController+KeyCodeTranslation.h"

static NSString * const kLocalKeyKey = @"keyboardKey";
static NSString * const kLocalFlagsKey = @"flags";

static SRKeyCodeTransformer *staticTransformer;

@implementation DKKeyboardShortcutLocalAction

+(void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		staticTransformer = [SRKeyCodeTransformer new];
		[DKLocalAction registerViewControllerClass:[DKKeyboardShortcutLocalActionConfigViewController class]
									   description:NSLocalizedString(@"DKKeyboardShortcutLocalAction title", @"")
							 forLocalActionOfClass:self];
	});
}

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super initWithPropertyListRepresentation:plist];

	if (self) {
		self.localKey = [plist valueForKey:kLocalKeyKey];
		self.flags = [[plist valueForKey:kLocalFlagsKey] unsignedIntegerValue];
	}
	return self;
}

-(id)initWithLocalKey:(NSString *)key flags:(NSUInteger)flags forDeviceKeyCode:(cec_user_control_code)deviceCode {
	self = [super initWithDeviceKeyCode:deviceCode];

	if (self) {
		self.localKey = key;
		self.flags = flags;
	}
	return self;
}

@synthesize parentMapping;

-(void)setLocalKeyFromKeyCode:(CGKeyCode)code {
	NSString *keyString = [staticTransformer transformedValue:@(code)];
	self.localKey = keyString;
}

+(NSSet *)keyPathsForValuesAffectingLocalTranslatedKeyCode {
	return [NSSet setWithObject:@"localKey"];
}

-(NSInteger)localTranslatedKeyCode {
	if (self.localKey.length == 0) return -1;
	return (NSInteger)[[staticTransformer reverseTransformedValue:self.localKey] integerValue];
}

-(id)propertyListRepresentation {
	NSString *keyStr = [DKCECDeviceController stringForKeyCode:self.deviceKeyCode];
	return @{ kDeviceKeyCodeKey : keyStr,
	kLocalKeyKey : self.localKey == nil ? @"" : self.localKey,
	kLocalFlagsKey : @(self.flags),
	kLocalActionPlistRepClassKey : NSStringFromClass(self.class)};
}

-(void)performActionWithKeyPress:(cec_keypress)keyPress {

	CGKeyCode theMainKey = self.localTranslatedKeyCode;
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


@end
