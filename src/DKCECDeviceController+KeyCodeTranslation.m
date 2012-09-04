//
//  DKCECDeviceController+KeyCodeTranslation.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 25/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKCECDeviceController+KeyCodeTranslation.h"

@implementation DKCECDeviceController (KeyCodeTranslation)

+(NSString *)stringForKeyCode:(cec_user_control_code)code {

	switch (code) {
		case CEC_USER_CONTROL_CODE_SELECT:
			return @"SELECT";
			break;
		case CEC_USER_CONTROL_CODE_UP:
			return @"UP";
			break;
		case CEC_USER_CONTROL_CODE_DOWN:
			return @"DOWN";
			break;
		case CEC_USER_CONTROL_CODE_LEFT:
			return @"LEFT";
			break;
		case CEC_USER_CONTROL_CODE_RIGHT:
			return @"RIGHT";
			break;
		case CEC_USER_CONTROL_CODE_RIGHT_UP:
			return @"RIGHT_UP";
			break;
		case CEC_USER_CONTROL_CODE_RIGHT_DOWN:
			return @"RIGHT_DOWN";
			break;
		case CEC_USER_CONTROL_CODE_LEFT_UP:
			return @"LEFT_UP";
			break;
		case CEC_USER_CONTROL_CODE_LEFT_DOWN:
			return @"LEFT_DOWN";
			break;
		case CEC_USER_CONTROL_CODE_ROOT_MENU:
			return @"ROOT_MENU";
			break;
		case CEC_USER_CONTROL_CODE_SETUP_MENU:
			return @"SETUP_MENU";
			break;
		case CEC_USER_CONTROL_CODE_CONTENTS_MENU:
			return @"CONTENTS_MENU";
			break;
		case CEC_USER_CONTROL_CODE_FAVORITE_MENU:
			return @"FAVORITE_MENU";
			break;
		case CEC_USER_CONTROL_CODE_EXIT:
			return @"EXIT";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER0:
			return @"NUMBER0";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER1:
			return @"NUMBER1";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER2:
			return @"NUMBER2";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER3:
			return @"NUMBER3";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER4:
			return @"NUMBER4";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER5:
			return @"NUMBER5";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER6:
			return @"NUMBER6";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER7:
			return @"NUMBER7";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER8:
			return @"NUMBER8";
			break;
		case CEC_USER_CONTROL_CODE_NUMBER9:
			return @"NUMBER9";
			break;
		case CEC_USER_CONTROL_CODE_DOT:
			return @"DOT";
			break;
		case CEC_USER_CONTROL_CODE_ENTER:
			return @"ENTER";
			break;
		case CEC_USER_CONTROL_CODE_CLEAR:
			return @"CLEAR";
			break;
		case CEC_USER_CONTROL_CODE_NEXT_FAVORITE:
			return @"NEXT_FAVORITE";
			break;
		case CEC_USER_CONTROL_CODE_CHANNEL_UP:
			return @"CHANNEL_UP";
			break;
		case CEC_USER_CONTROL_CODE_CHANNEL_DOWN:
			return @"CHANNEL_DOWN";
			break;
		case CEC_USER_CONTROL_CODE_PREVIOUS_CHANNEL:
			return @"PREVIOUS_CHANNEL";
			break;
		case CEC_USER_CONTROL_CODE_SOUND_SELECT:
			return @"SOUND_SELECT";
			break;
		case CEC_USER_CONTROL_CODE_INPUT_SELECT:
			return @"INPUT_SELECT";
			break;
		case CEC_USER_CONTROL_CODE_DISPLAY_INFORMATION:
			return @"DISPLAY_INFORMATION";
			break;
		case CEC_USER_CONTROL_CODE_HELP:
			return @"HELP";
			break;
		case CEC_USER_CONTROL_CODE_PAGE_UP:
			return @"PAGE_UP";
			break;
		case CEC_USER_CONTROL_CODE_PAGE_DOWN:
			return @"PAGE_DOWN";
			break;
		case CEC_USER_CONTROL_CODE_POWER:
			return @"POWER";
			break;
		case CEC_USER_CONTROL_CODE_VOLUME_UP:
			return @"VOLUME_UP";
			break;
		case CEC_USER_CONTROL_CODE_VOLUME_DOWN:
			return @"VOLUME_DOWN";
			break;
		case CEC_USER_CONTROL_CODE_MUTE:
			return @"MUTE";
			break;
		case CEC_USER_CONTROL_CODE_PLAY:
			return @"PLAY";
			break;
		case CEC_USER_CONTROL_CODE_STOP:
			return @"STOP";
			break;
		case CEC_USER_CONTROL_CODE_PAUSE:
			return @"PAUSE";
			break;
		case CEC_USER_CONTROL_CODE_RECORD:
			return @"RECORD";
			break;
		case CEC_USER_CONTROL_CODE_REWIND:
			return @"REWIND";
			break;
		case CEC_USER_CONTROL_CODE_FAST_FORWARD:
			return @"FAST_FORWARD";
			break;
		case CEC_USER_CONTROL_CODE_EJECT:
			return @"EJECT";
			break;
		case CEC_USER_CONTROL_CODE_FORWARD:
			return @"FORWARD";
			break;
		case CEC_USER_CONTROL_CODE_BACKWARD:
			return @"BACKWARD";
			break;
		case CEC_USER_CONTROL_CODE_STOP_RECORD:
			return @"STOP_RECORD";
			break;
		case CEC_USER_CONTROL_CODE_PAUSE_RECORD:
			return @"PAUSE_RECORD";
			break;
		case CEC_USER_CONTROL_CODE_ANGLE:
			return @"ANGLE";
			break;
		case CEC_USER_CONTROL_CODE_SUB_PICTURE:
			return @"SUB_PICTURE";
			break;
		case CEC_USER_CONTROL_CODE_VIDEO_ON_DEMAND:
			return @"VIDEO_ON_DEMAND";
			break;
		case CEC_USER_CONTROL_CODE_ELECTRONIC_PROGRAM_GUIDE:
			return @"ELECTRONIC_PROGRAM_GUIDE";
			break;
		case CEC_USER_CONTROL_CODE_TIMER_PROGRAMMING:
			return @"TIMER_PROGRAMMING";
			break;
		case CEC_USER_CONTROL_CODE_INITIAL_CONFIGURATION:
			return @"INITIAL_CONFIGURATION";
			break;
		case CEC_USER_CONTROL_CODE_PLAY_FUNCTION:
			return @"PLAY_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_PAUSE_PLAY_FUNCTION:
			return @"PAUSE_PLAY_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_RECORD_FUNCTION:
			return @"RECORD_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_PAUSE_RECORD_FUNCTION:
			return @"PAUSE_RECORD_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_STOP_FUNCTION:
			return @"STOP_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_MUTE_FUNCTION:
			return @"MUTE_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_RESTORE_VOLUME_FUNCTION:
			return @"RESTORE_VOLUME_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_TUNE_FUNCTION:
			return @"TUNE_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_SELECT_MEDIA_FUNCTION:
			return @"SELECT_MEDIA_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_SELECT_AV_INPUT_FUNCTION:
			return @"SELECT_AV_INPUT_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_SELECT_AUDIO_INPUT_FUNCTION:
			return @"SELECT_AUDIO_INPUT_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_POWER_TOGGLE_FUNCTION:
			return @"POWER_TOGGLE_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_POWER_OFF_FUNCTION:
			return @"POWER_OFF_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_POWER_ON_FUNCTION:
			return @"POWER_ON_FUNCTION";
			break;
		case CEC_USER_CONTROL_CODE_F1_BLUE:
			return @"F1_BLUE";
			break;
		case CEC_USER_CONTROL_CODE_F2_RED:
			return @"F2_RED";
			break;
		case CEC_USER_CONTROL_CODE_F3_GREEN:
			return @"F3_GREEN";
			break;
		case CEC_USER_CONTROL_CODE_F4_YELLOW:
			return @"F4_YELLOW";
			break;
		case CEC_USER_CONTROL_CODE_F5:
			return @"F5";
			break;
		case CEC_USER_CONTROL_CODE_DATA:
			return @"DATA";
			break;
		case CEC_USER_CONTROL_CODE_AN_RETURN:
			return @"AN_RETURN";
			break;
		case CEC_USER_CONTROL_CODE_AN_CHANNELS_LIST:
			return @"AN_CHANNELS_LIST";
			break;
		default:
			return @"UNKNOWN";
			break;
	}
}

+(cec_user_control_code)keyCodeForString:(NSString *)str {

	if (str.length == 0)
		return CEC_USER_CONTROL_CODE_UNKNOWN;
	else if ([str caseInsensitiveCompare:@"SELECT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_SELECT;
	else if ([str caseInsensitiveCompare:@"UP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_UP;
	else if ([str caseInsensitiveCompare:@"DOWN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_DOWN;
	else if ([str caseInsensitiveCompare:@"LEFT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_LEFT;
	else if ([str caseInsensitiveCompare:@"RIGHT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_RIGHT;
	else if ([str caseInsensitiveCompare:@"RIGHT_UP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_RIGHT_UP;
	else if ([str caseInsensitiveCompare:@"RIGHT_DOWN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_RIGHT_DOWN;
	else if ([str caseInsensitiveCompare:@"LEFT_UP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_LEFT_UP;
	else if ([str caseInsensitiveCompare:@"LEFT_DOWN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_LEFT_DOWN;
	else if ([str caseInsensitiveCompare:@"ROOT_MENU"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_ROOT_MENU;
	else if ([str caseInsensitiveCompare:@"SETUP_MENU"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_SETUP_MENU;
	else if ([str caseInsensitiveCompare:@"CONTENTS_MENU"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_CONTENTS_MENU;
	else if ([str caseInsensitiveCompare:@"FAVORITE_MENU"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_FAVORITE_MENU;
	else if ([str caseInsensitiveCompare:@"EXIT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_EXIT;
	else if ([str caseInsensitiveCompare:@"NUMBER0"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER0;
	else if ([str caseInsensitiveCompare:@"NUMBER1"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER1;
	else if ([str caseInsensitiveCompare:@"NUMBER2"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER2;
	else if ([str caseInsensitiveCompare:@"NUMBER3"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER3;
	else if ([str caseInsensitiveCompare:@"NUMBER4"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER4;
	else if ([str caseInsensitiveCompare:@"NUMBER5"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER5;
	else if ([str caseInsensitiveCompare:@"NUMBER6"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER6;
	else if ([str caseInsensitiveCompare:@"NUMBER7"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER7;
	else if ([str caseInsensitiveCompare:@"NUMBER8"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER8;
	else if ([str caseInsensitiveCompare:@"NUMBER9"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NUMBER9;
	else if ([str caseInsensitiveCompare:@"DOT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_DOT;
	else if ([str caseInsensitiveCompare:@"ENTER"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_ENTER;
	else if ([str caseInsensitiveCompare:@"CLEAR"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_CLEAR;
	else if ([str caseInsensitiveCompare:@"NEXT_FAVORITE"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_NEXT_FAVORITE;
	else if ([str caseInsensitiveCompare:@"CHANNEL_UP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_CHANNEL_UP;
	else if ([str caseInsensitiveCompare:@"CHANNEL_DOWN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_CHANNEL_DOWN;
	else if ([str caseInsensitiveCompare:@"PREVIOUS_CHANNEL"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PREVIOUS_CHANNEL;
	else if ([str caseInsensitiveCompare:@"SOUND_SELECT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_SOUND_SELECT;
	else if ([str caseInsensitiveCompare:@"INPUT_SELECT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_INPUT_SELECT;
	else if ([str caseInsensitiveCompare:@"DISPLAY_INFORMATION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_DISPLAY_INFORMATION;
	else if ([str caseInsensitiveCompare:@"HELP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_HELP;
	else if ([str caseInsensitiveCompare:@"PAGE_UP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PAGE_UP;
	else if ([str caseInsensitiveCompare:@"PAGE_DOWN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PAGE_DOWN;
	else if ([str caseInsensitiveCompare:@"POWER"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_POWER;
	else if ([str caseInsensitiveCompare:@"VOLUME_UP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_VOLUME_UP;
	else if ([str caseInsensitiveCompare:@"VOLUME_DOWN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_VOLUME_DOWN;
	else if ([str caseInsensitiveCompare:@"MUTE"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_MUTE;
	else if ([str caseInsensitiveCompare:@"PLAY"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PLAY;
	else if ([str caseInsensitiveCompare:@"STOP"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_STOP;
	else if ([str caseInsensitiveCompare:@"PAUSE"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PAUSE;
	else if ([str caseInsensitiveCompare:@"RECORD"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_RECORD;
	else if ([str caseInsensitiveCompare:@"REWIND"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_REWIND;
	else if ([str caseInsensitiveCompare:@"FAST_FORWARD"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_FAST_FORWARD;
	else if ([str caseInsensitiveCompare:@"EJECT"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_EJECT;
	else if ([str caseInsensitiveCompare:@"FORWARD"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_FORWARD;
	else if ([str caseInsensitiveCompare:@"BACKWARD"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_BACKWARD;
	else if ([str caseInsensitiveCompare:@"STOP_RECORD"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_STOP_RECORD;
	else if ([str caseInsensitiveCompare:@"PAUSE_RECORD"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PAUSE_RECORD;
	else if ([str caseInsensitiveCompare:@"ANGLE"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_ANGLE;
	else if ([str caseInsensitiveCompare:@"SUB_PICTURE"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_SUB_PICTURE;
	else if ([str caseInsensitiveCompare:@"VIDEO_ON_DEMAND"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_VIDEO_ON_DEMAND;
	else if ([str caseInsensitiveCompare:@"ELECTRONIC_PROGRAM_GUIDE"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_ELECTRONIC_PROGRAM_GUIDE;
	else if ([str caseInsensitiveCompare:@"TIMER_PROGRAMMING"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_TIMER_PROGRAMMING;
	else if ([str caseInsensitiveCompare:@"INITIAL_CONFIGURATION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_INITIAL_CONFIGURATION;
	else if ([str caseInsensitiveCompare:@"PLAY_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PLAY_FUNCTION;
	else if ([str caseInsensitiveCompare:@"PAUSE_PLAY_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PAUSE_PLAY_FUNCTION;
	else if ([str caseInsensitiveCompare:@"RECORD_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_RECORD_FUNCTION;
	else if ([str caseInsensitiveCompare:@"PAUSE_RECORD_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_PAUSE_RECORD_FUNCTION;
	else if ([str caseInsensitiveCompare:@"STOP_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_STOP_FUNCTION;
	else if ([str caseInsensitiveCompare:@"MUTE_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_MUTE_FUNCTION;
	else if ([str caseInsensitiveCompare:@"RESTORE_VOLUME_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_RESTORE_VOLUME_FUNCTION;
	else if ([str caseInsensitiveCompare:@"TUNE_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_TUNE_FUNCTION;
	else if ([str caseInsensitiveCompare:@"SELECT_MEDIA_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_SELECT_MEDIA_FUNCTION;
	else if ([str caseInsensitiveCompare:@"SELECT_AV_INPUT_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_SELECT_AV_INPUT_FUNCTION;
	else if ([str caseInsensitiveCompare:@"SELECT_AUDIO_INPUT_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_SELECT_AUDIO_INPUT_FUNCTION;
	else if ([str caseInsensitiveCompare:@"POWER_TOGGLE_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_POWER_TOGGLE_FUNCTION;
	else if ([str caseInsensitiveCompare:@"POWER_OFF_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_POWER_OFF_FUNCTION;
	else if ([str caseInsensitiveCompare:@"POWER_ON_FUNCTION"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_POWER_ON_FUNCTION;
	else if ([str caseInsensitiveCompare:@"F1_BLUE"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_F1_BLUE;
	else if ([str caseInsensitiveCompare:@"F2_RED"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_F2_RED;
	else if ([str caseInsensitiveCompare:@"F3_GREEN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_F3_GREEN;
	else if ([str caseInsensitiveCompare:@"F4_YELLOW"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_F4_YELLOW;
	else if ([str caseInsensitiveCompare:@"F5"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_F5;
	else if ([str caseInsensitiveCompare:@"DATA"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_DATA;
	else if ([str caseInsensitiveCompare:@"AN_RETURN"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_AN_RETURN;
	else if ([str caseInsensitiveCompare:@"AN_CHANNELS_LIST"] == NSOrderedSame)
		return CEC_USER_CONTROL_CODE_AN_CHANNELS_LIST;
	else
		return CEC_USER_CONTROL_CODE_UNKNOWN;
}

@end
