//
//  Constants.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 20/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Foundation/Foundation.h>

static NSString * const kLocalActionPlistRepClassKey = @"class";
static NSString * const kDeviceKeyCodeKey = @"deviceCode";
static NSString * const kApplicationLaunchedAtStartupParameter = @"LaunchedAtStartup";

static NSString * const kActionViewControllerClassKey = @"kActionViewControllerClassKey";
static NSString * const kActionViewControllerDescriptionKey = @"kActionViewControllerDescriptionKey";
static NSString * const kActionViewControllerActionClassKey = @"kActionViewControllerActionClassKey";

static NSString * const kLogLibCECUserDefaultsKey = @"LogLibCEC";
static NSString * const kPhysicalAddressUserDefaultsKey = @"PhysicalAddress";
static NSString * const kSkipQuitAlertUserDefaultsKey = @"SkipQuitPrompt";
static NSString * const kHasDoneFirstLaunchUserDefaultsKey = @"HasDoneFirstLaunch";
static NSString * const kOnTVOffUserDefaultsKey = @"OnTVOff";
static NSString * const kOnTVOnUserDefaultsKey = @"OnTVOn";
static NSString * const kOnTVBecameActiveUserDefaultsKey = @"OnTVBecameActive";
static NSString * const kOnTVLostActiveUserDefaultsKey = @"OnTVLostActive";
static NSString * const kOnTVActionScriptURLUserDefaultsKey = @"TVActionScript";
static NSString * const kOnMacAwokeUserDefaultsKey = @"OnMacAwoke";
static NSString * const kOnMacSleptUserDefaultsKey = @"OnMacSlept";

static NSString * const kApplicationShouldShowMouseGridNotificationName = @"MouseGrid!";
static NSString * const kApplicationShouldShowVirtualRemoteNotificationName = @"Remote!";

static NSString * const kAppleScriptTVOnFunctionName = @"CouchSlouch_TVOn";
static NSString * const kAppleScriptTVOffFunctionName = @"CouchSlouch_TVOff";
static NSString * const kAppleScriptBecameActiveFunctionName = @"CouchSlouch_BecameActiveTVSource";
static NSString * const kAppleScriptLostActiveFunctionName = @"CouchSlouch_LostActiveTVSource";
static NSString * const kAppleScriptMacAwokeFunctionName = @"CouchSlouch_MacAwoke";
static NSString * const kAppleScriptMacSleptFunctionName = @"CouchSlouch_MacSlept";

typedef NS_ENUM(NSUInteger, DKCECMacBehaviourAction) {
	DKCECBehaviourActionNothing = 0,
	DKCECBehaviourActionSleepComputer = 1,
	DKCECBehaviourActionShutdownComputer = 2,
	DKCECBehaviourActionTriggerScript = 3,
	DKCECBehaviourActionWakeUpComputer = 4
};

typedef NS_ENUM(NSUInteger, DKCECTVBehaviourAction) {
	DKCECTVBehaviourActionNothing = 0,
	DKCECTVBehaviourActionPowerOnTV = 1,
	DKCECTVBehaviourActionPowerOffTV = 2,
	DKCECTVBehaviourActionTriggerScript = 3
};


