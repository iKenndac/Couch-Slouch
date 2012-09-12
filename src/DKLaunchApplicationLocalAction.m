//
//  DKLaunchApplicationLocalAction.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKLaunchApplicationLocalAction.h"
#import "Constants.h"
#import "DKLaunchApplicationLocalActionConfigViewController.h"
#import "DKCECDeviceController+KeyCodeTranslation.h"

static NSString * const kBundleIdentifierKey = @"bundleId";

@interface DKLaunchApplicationLocalAction ()

@end

@implementation DKLaunchApplicationLocalAction

+(void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[DKLocalAction registerViewControllerClass:[DKLaunchApplicationLocalActionConfigViewController class]
										   description:NSLocalizedString(@"DKLaunchApplicationLocalAction title", @"")
								 forLocalActionOfClass:self];
	});
}

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

@synthesize parentMapping;

-(id)propertyListRepresentation {
	NSString *keyStr = [DKCECDeviceController stringForKeyCode:self.deviceKeyCode];
	return @{ kDeviceKeyCodeKey : keyStr,
	kBundleIdentifierKey : self.bundleIdentifier == nil ? @"" : self.bundleIdentifier,
	kLocalActionPlistRepClassKey : NSStringFromClass(self.class)};
}

-(void)performActionWithKeyPress:(cec_keypress)keyPress {

	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:self.bundleIdentifier
														 options:NSWorkspaceLaunchDefault
								  additionalEventParamDescriptor:nil
												launchIdentifier:nil];
}

@end
