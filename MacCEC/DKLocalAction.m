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

static NSMutableArray *registeredViewControllers;

+(void)initialize {
	registeredViewControllers = [NSMutableArray new];
}

+(void)registerViewControllerClass:(Class)controllerClass description:(NSString *)desc forLocalActionOfClass:(Class)localActionClass {
	NSDictionary *dict = @{ kActionViewControllerClassKey : controllerClass,
			kActionViewControllerDescriptionKey : desc,
			kActionViewControllerActionClassKey : localActionClass };
	[registeredViewControllers addObject:dict];
}

+(NSArray *)registeredConfigViewControllers {
	return [NSArray arrayWithArray:registeredViewControllers];
}

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
	switch (self.deviceKeyCode) {
		case CEC_USER_CONTROL_CODE_SELECT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_SELECT", @"");
			break;
		case CEC_USER_CONTROL_CODE_UP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_UP", @"");
			break;
		case CEC_USER_CONTROL_CODE_DOWN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_DOWN", @"");
			break;
		case CEC_USER_CONTROL_CODE_LEFT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_LEFT", @"");
			break;
		case CEC_USER_CONTROL_CODE_RIGHT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_RIGHT", @"");
			break;
		case CEC_USER_CONTROL_CODE_RIGHT_UP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_RIGHT_UP", @"");
			break;
		case CEC_USER_CONTROL_CODE_RIGHT_DOWN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_RIGHT_DOWN", @"");
			break;
		case CEC_USER_CONTROL_CODE_LEFT_UP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_LEFT_UP", @"");
			break;
		case CEC_USER_CONTROL_CODE_LEFT_DOWN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_LEFT_DOWN", @"");
			break;
		case CEC_USER_CONTROL_CODE_ROOT_MENU:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_ROOT_MENU", @"");
			break;
		case CEC_USER_CONTROL_CODE_SETUP_MENU:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_SETUP_MENU", @"");
			break;
		case CEC_USER_CONTROL_CODE_CONTENTS_MENU:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_CONTENTS_MENU", @"");
			break;
		case CEC_USER_CONTROL_CODE_FAVORITE_MENU:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_FAVORITE_MENU", @"");
			break;
		case CEC_USER_CONTROL_CODE_EXIT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_EXIT", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER0:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER0", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER1:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER1", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER2:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER2", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER3:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER3", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER4:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER4", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER5:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER5", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER6:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER6", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER7:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER7", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER8:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER8", @"");
			break;
		case CEC_USER_CONTROL_CODE_NUMBER9:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NUMBER9", @"");
			break;
		case CEC_USER_CONTROL_CODE_DOT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_DOT", @"");
			break;
		case CEC_USER_CONTROL_CODE_ENTER:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_ENTER", @"");
			break;
		case CEC_USER_CONTROL_CODE_CLEAR:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_CLEAR", @"");
			break;
		case CEC_USER_CONTROL_CODE_NEXT_FAVORITE:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_NEXT_FAVORITE", @"");
			break;
		case CEC_USER_CONTROL_CODE_CHANNEL_UP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_CHANNEL_UP", @"");
			break;
		case CEC_USER_CONTROL_CODE_CHANNEL_DOWN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_CHANNEL_DOWN", @"");
			break;
		case CEC_USER_CONTROL_CODE_PREVIOUS_CHANNEL:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PREVIOUS_CHANNEL", @"");
			break;
		case CEC_USER_CONTROL_CODE_SOUND_SELECT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_SOUND_SELECT", @"");
			break;
		case CEC_USER_CONTROL_CODE_INPUT_SELECT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_INPUT_SELECT", @"");
			break;
		case CEC_USER_CONTROL_CODE_DISPLAY_INFORMATION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_DISPLAY_INFORMATION", @"");
			break;
		case CEC_USER_CONTROL_CODE_HELP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_HELP", @"");
			break;
		case CEC_USER_CONTROL_CODE_PAGE_UP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PAGE_UP", @"");
			break;
		case CEC_USER_CONTROL_CODE_PAGE_DOWN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PAGE_DOWN", @"");
			break;
		case CEC_USER_CONTROL_CODE_POWER:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_POWER", @"");
			break;
		case CEC_USER_CONTROL_CODE_VOLUME_UP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_VOLUME_UP", @"");
			break;
		case CEC_USER_CONTROL_CODE_VOLUME_DOWN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_VOLUME_DOWN", @"");
			break;
		case CEC_USER_CONTROL_CODE_MUTE:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_MUTE", @"");
			break;
		case CEC_USER_CONTROL_CODE_PLAY:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PLAY", @"");
			break;
		case CEC_USER_CONTROL_CODE_STOP:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_STOP", @"");
			break;
		case CEC_USER_CONTROL_CODE_PAUSE:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PAUSE", @"");
			break;
		case CEC_USER_CONTROL_CODE_RECORD:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_RECORD", @"");
			break;
		case CEC_USER_CONTROL_CODE_REWIND:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_REWIND", @"");
			break;
		case CEC_USER_CONTROL_CODE_FAST_FORWARD:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_FAST_FORWARD", @"");
			break;
		case CEC_USER_CONTROL_CODE_EJECT:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_EJECT", @"");
			break;
		case CEC_USER_CONTROL_CODE_FORWARD:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_FORWARD", @"");
			break;
		case CEC_USER_CONTROL_CODE_BACKWARD:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_BACKWARD", @"");
			break;
		case CEC_USER_CONTROL_CODE_STOP_RECORD:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_STOP_RECORD", @"");
			break;
		case CEC_USER_CONTROL_CODE_PAUSE_RECORD:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PAUSE_RECORD", @"");
			break;
		case CEC_USER_CONTROL_CODE_ANGLE:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_ANGLE", @"");
			break;
		case CEC_USER_CONTROL_CODE_SUB_PICTURE:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_SUB_PICTURE", @"");
			break;
		case CEC_USER_CONTROL_CODE_VIDEO_ON_DEMAND:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_VIDEO_ON_DEMAND", @"");
			break;
		case CEC_USER_CONTROL_CODE_ELECTRONIC_PROGRAM_GUIDE:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_ELECTRONIC_PROGRAM_GUIDE", @"");
			break;
		case CEC_USER_CONTROL_CODE_TIMER_PROGRAMMING:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_TIMER_PROGRAMMING", @"");
			break;
		case CEC_USER_CONTROL_CODE_INITIAL_CONFIGURATION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_INITIAL_CONFIGURATION", @"");
			break;
		case CEC_USER_CONTROL_CODE_PLAY_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PLAY_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_PAUSE_PLAY_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PAUSE_PLAY_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_RECORD_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_RECORD_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_PAUSE_RECORD_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_PAUSE_RECORD_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_STOP_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_STOP_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_MUTE_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_MUTE_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_RESTORE_VOLUME_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_RESTORE_VOLUME_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_TUNE_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_TUNE_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_SELECT_MEDIA_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_SELECT_MEDIA_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_SELECT_AV_INPUT_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_SELECT_AV_INPUT_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_SELECT_AUDIO_INPUT_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_SELECT_AUDIO_INPUT_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_POWER_TOGGLE_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_POWER_TOGGLE_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_POWER_OFF_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_POWER_OFF_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_POWER_ON_FUNCTION:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_POWER_ON_FUNCTION", @"");
			break;
		case CEC_USER_CONTROL_CODE_F1_BLUE:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_F1_BLUE", @"");
			break;
		case CEC_USER_CONTROL_CODE_F2_RED:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_F2_RED", @"");
			break;
		case CEC_USER_CONTROL_CODE_F3_GREEN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_F3_GREEN", @"");
			break;
		case CEC_USER_CONTROL_CODE_F4_YELLOW:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_F4_YELLOW", @"");
			break;
		case CEC_USER_CONTROL_CODE_F5:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_F5", @"");
			break;
		case CEC_USER_CONTROL_CODE_DATA:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_DATA", @"");
			break;
		case CEC_USER_CONTROL_CODE_AN_RETURN:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_AN_RETURN", @"");
			break;
		case CEC_USER_CONTROL_CODE_AN_CHANNELS_LIST:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_AN_CHANNELS_LIST", @"");
			break;
		default:
			return NSLocalizedString(@"CEC_USER_CONTROL_CODE_UNKNOWN", @"");
			break;
	}
}

@end
