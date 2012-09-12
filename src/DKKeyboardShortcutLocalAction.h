//
//  DKSingleKeypressLocalAction.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Foundation/Foundation.h>
#import "DKLocalAction.h"
#import "cectypes.h"

@interface DKKeyboardShortcutLocalAction : DKLocalAction <DKLocalAction>

-(id)initWithLocalKey:(NSString *)key flags:(NSUInteger)flags forDeviceKeyCode:(cec_user_control_code)deviceCode;

@property (nonatomic, readwrite, copy) NSString *localKey;
@property (nonatomic, readonly) NSInteger localTranslatedKeyCode;
@property (nonatomic, readwrite) NSUInteger flags;

-(void)setLocalKeyFromKeyCode:(CGKeyCode)code;

@end
