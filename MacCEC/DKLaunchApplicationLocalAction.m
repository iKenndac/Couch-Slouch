//
//  DKLaunchApplicationLocalAction.m
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKLaunchApplicationLocalAction.h"
#import "Constants.h"

static NSString * const kBundleIdentifierKey = @"bundleId";

@interface DKLaunchApplicationLocalAction ()

@property (nonatomic, readwrite, copy) NSString *bundleIdentifier;

@end

@implementation DKLaunchApplicationLocalAction

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super initWithPropertyListRepresentation:plist];

	if (self) {
		self.bundleIdentifier = [plist valueForKey:kBundleIdentifierKey];
	}
	return self;
}

-(id)initWithBundleIdentifier:(NSString *)identifier forDeviceKeyCode:(cec_user_control_code)deviceCode {
	self = [super initWithDeviceKeyCode:deviceCode];

	if (self) {
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

@end
