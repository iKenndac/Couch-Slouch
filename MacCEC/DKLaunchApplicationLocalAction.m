//
//  DKLaunchApplicationLocalAction.m
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKLaunchApplicationLocalAction.h"
#import "Constants.h"

static NSString * const kDeviceKeyCodeKey = @"deviceCode";
static NSString * const kBundleIdentifierKey = @"bundleId";

@interface DKLaunchApplicationLocalAction ()

@property (nonatomic, readwrite) cec_user_control_code deviceKeyCode;
@property (nonatomic, readwrite, copy) NSString *bundleIdentifier;

@end

@implementation DKLaunchApplicationLocalAction

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super init];

	if (self) {
		self.deviceKeyCode = [[plist valueForKey:kDeviceKeyCodeKey] integerValue];
		self.bundleIdentifier = [plist valueForKey:kBundleIdentifierKey];
	}
	return self;
}

-(id)initWithBundleIdentifier:(NSString *)identifier forDeviceKeyCode:(cec_user_control_code)deviceCode {
	self = [super init];

	if (self) {
		self.deviceKeyCode = deviceCode;
		self.bundleIdentifier = identifier;
	}
	return self;
}

-(id)propertyListRepresentation {
	return @{ kDeviceKeyCodeKey : @(self.deviceKeyCode),
	kBundleIdentifierKey : self.bundleIdentifier,
	kLocalActionPlistRepClassKey : NSStringFromClass(self.class)};
}

-(void)performActionWithKeyPress:(cec_keypress)keyPress {

	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:self.bundleIdentifier
														 options:NSWorkspaceLaunchDefault
								  additionalEventParamDescriptor:nil
												launchIdentifier:nil];
}

-(BOOL)matchesKeyPress:(cec_keypress)keyPress {
	return keyPress.keycode == self.deviceKeyCode;
}

@end
