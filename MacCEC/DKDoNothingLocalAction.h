//
//  DKDoNothingLocalAction.h
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKLocalAction.h"

@interface DKDoNothingLocalAction : NSObject <DKLocalAction>

-(id)initWithDeviceKeyCode:(cec_user_control_code)deviceCode;

@property (nonatomic, readonly) cec_user_control_code deviceKeyCode;

@end
