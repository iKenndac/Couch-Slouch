//
//  DKCECDeviceController+AppleScript.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 30/05/15.
//  Copyright (c) 2015 Daniel Kennett. All rights reserved.
//

#import "DKCECDeviceController.h"

@interface DKCECDeviceController (AppleScript)
@end

@interface DKCECDeviceControllerTurnOnTVCommand : NSScriptCommand
@end

@interface DKCECDeviceControllerTurnOffTVCommand : NSScriptCommand
@end

@interface DKCECDeviceControllerBecomeActiveSourceCommand : NSScriptCommand
@end