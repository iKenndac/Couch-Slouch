//
//  DKLaunchApplicationLocalAction.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 22/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Foundation/Foundation.h>
#import "DKLocalAction.h"

@interface DKLaunchApplicationLocalAction : DKLocalAction <DKLocalAction>

-(id)initWithBundleIdentifier:(NSString *)identifier forDeviceKeyCode:(cec_user_control_code)deviceCode;

@property (nonatomic, readwrite, copy) NSString *bundleIdentifier;

@end
