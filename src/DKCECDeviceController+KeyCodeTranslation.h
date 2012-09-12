//
//  DKCECDeviceController+KeyCodeTranslation.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 25/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKCECDeviceController.h"

@interface DKCECDeviceController (KeyCodeTranslation)

+(NSString *)stringForKeyCode:(cec_user_control_code)code;
+(cec_user_control_code)keyCodeForString:(NSString *)str;

@end
