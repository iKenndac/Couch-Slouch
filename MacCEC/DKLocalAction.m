//
//  DKDoNothingLocalAction.m
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKLocalAction.h"
#import "Constants.h"

@interface DKLocalAction ()

@property (nonatomic, readwrite) cec_user_control_code deviceKeyCode;

@end

@implementation DKLocalAction

-(id)initWithDeviceKeyCode:(cec_user_control_code)deviceCode {
	self = [super init];

	if (self) {
		self.deviceKeyCode = deviceCode;
	}
	return self;
}

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super init];

	if (self) {
		self.deviceKeyCode = [[plist valueForKey:kDeviceKeyCodeKey] integerValue];
	}
	return self;
}

-(id)propertyListRepresentation { return [NSDictionary dictionary]; }
-(void)performActionWithKeyPress:(cec_keypress)keyPress {}
-(BOOL)matchesKeyPress:(cec_keypress)keyPress { return keyPress.keycode == self.deviceKeyCode; }

-(NSString *)deviceKeyCodeDisplayName {
	return nil;
}

@end
