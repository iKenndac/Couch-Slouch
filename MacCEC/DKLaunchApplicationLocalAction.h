//
//  DKLaunchApplicationLocalAction.h
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKLocalAction.h"

@interface DKLaunchApplicationLocalAction : NSObject

-(id)initWithBundleIdentifier:(NSString *)identifier forDeviceKeyCode:(cec_user_control_code)deviceCode;

@property (nonatomic, readonly) cec_user_control_code deviceKeyCode;
@property (nonatomic, readonly, copy) NSString *bundleIdentifier;

@end