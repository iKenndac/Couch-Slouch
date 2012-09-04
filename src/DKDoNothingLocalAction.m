//
//  DKDoNothingLocalAction.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKDoNothingLocalAction.h"
#import "Constants.h"
#import "DKCECDeviceController+KeyCodeTranslation.h"

@implementation DKDoNothingLocalAction

+(void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[DKLocalAction registerViewControllerClass:nil
									   description:NSLocalizedString(@"DKDoNothingLocalAction title", @"")
							 forLocalActionOfClass:self];
	});
}

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super initWithPropertyListRepresentation:plist];

	if (self) {
	}
	return self;
}

@synthesize parentMapping;

-(id)propertyListRepresentation {
	NSString *keyStr = [DKCECDeviceController stringForKeyCode:self.deviceKeyCode];
	return @{ kDeviceKeyCodeKey : keyStr,
	kLocalActionPlistRepClassKey : NSStringFromClass(self.class)};
}

-(void)performActionWithKeyPress:(cec_keypress)keyPress {}

-(BOOL)matchesKeyPress:(cec_keypress)keyPress {
	return keyPress.keycode == self.deviceKeyCode;
}

@end
