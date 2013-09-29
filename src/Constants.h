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
static NSString * const kOnMacAwokeUserDefaultsKey = @"OnMacAwoke";
static NSString * const kOnMacSleptUserDefaultsKey = @"OnMacSlept";
static NSString * const kHasInstalledSampleScriptUserDefaultsKey = @"InstalledSampleScript";

static NSString * const kOnActionScriptUserDefaultsKeySuffix = @"Script";

static NSString * const kApplicationShouldShowMouseGridNotificationName = @"MouseGrid!";
static NSString * const kApplicationShouldShowVirtualRemoteNotificationName = @"Remote!";

static NSString * const kAppleScriptTVOnFunctionName = @"CouchSlouch_TVOn";
static NSString * const kAppleScriptTVOffFunctionName = @"CouchSlouch_TVOff";
static NSString * const kAppleScriptBecameActiveFunctionName = @"CouchSlouch_BecameActiveTVSource";
static NSString * const kAppleScriptLostActiveFunctionName = @"CouchSlouch_LostActiveTVSource";
static NSString * const kAppleScriptMacAwokeFunctionName = @"CouchSlouch_MacAwoke";
static NSString * const kAppleScriptMacSleptFunctionName = @"CouchSlouch_MacSlept";

static NSString * const kCouchSlouchWebsiteURL = @"http://www.couch-slouch.com/";
static NSString * const kApplicationSupportFolderName = @"Couch Slouch";
static NSString * const kScriptsFolderName = @"Scripts";
static NSString * const kExampleScriptName = @"Couch Slouch Example Script.scpt";

typedef NS_ENUM(NSUInteger, DKCECCommonBehaviourAction) {
	DKCECCommonBehaviourActionNothing = 0,
	DKCECCommonBehaviourActionTriggerScript = 1,
};

typedef NS_ENUM(NSUInteger, DKCECMacBehaviourAction) {
	DKCECBehaviourActionNothing = 0,
	DKCECBehaviourActionTriggerScript = 1,
	DKCECBehaviourActionSleepComputer = 100,
	DKCECBehaviourActionShutdownComputer = 101,
	DKCECBehaviourActionWakeUpComputer = 102
};

typedef NS_ENUM(NSUInteger, DKCECTVBehaviourAction) {
	DKCECTVBehaviourActionNothing = 0,
	DKCECTVBehaviourActionTriggerScript = 1,
	DKCECTVBehaviourActionPowerOnTV = 100,
	DKCECTVBehaviourActionPowerOffTV = 101,
};


