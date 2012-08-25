//
//  DKCECDeviceController+KeyCodeTranslation.h
//  MacCEC
//
//  Created by Daniel Kennett on 25/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKCECDeviceController.h"

@interface DKCECDeviceController (KeyCodeTranslation)

+(NSString *)stringForKeyCode:(cec_user_control_code)code;
+(cec_user_control_code)keyCodeForString:(NSString *)str;

@end
