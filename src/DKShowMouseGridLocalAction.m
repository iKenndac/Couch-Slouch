//
//  DKShowMouseGridLocalAction.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 29/09/2012.
//  For license information, see LICENSE.markdown
//

#import "DKShowMouseGridLocalAction.h"
#import "Constants.h"
#import "DKCECDeviceController+KeyCodeTranslation.h"

@implementation DKShowMouseGridLocalAction

+(void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[DKLocalAction registerViewControllerClass:nil
									   description:NSLocalizedString(@"DKShowMouseGridLocalAction title", @"")
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

-(void)performActionWithKeyPress:(cec_keypress)keyPress {
	[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationShouldShowMouseGridNotificationName
														object:self];
}

@end
