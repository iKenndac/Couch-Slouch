//
//  DKDoNothingLocalAction.m
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKDoNothingLocalAction.h"
#import "Constants.h"

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

-(id)propertyListRepresentation {
	return @{ kLocalActionPlistRepClassKey : NSStringFromClass(self.class)};
}

-(void)performActionWithKeyPress:(cec_keypress)keyPress {}

-(BOOL)matchesKeyPress:(cec_keypress)keyPress {
	return keyPress.keycode == self.deviceKeyCode;
}

@end
