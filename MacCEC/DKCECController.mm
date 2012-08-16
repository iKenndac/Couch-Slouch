//
//  DKCECController.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKCECController.h"
#import "cecc.h"

using namespace CEC;

// ------------- Callbacks ------------------

static int CBCecLogMessage(void *param, const cec_log_message &) { return 0; }
static int CBCecKeyPress(void *param, const cec_keypress &) { return 0; }
static int CBCecCommand(void *param, const cec_command &) { return 0; }
static int CBCecConfigurationChanged(void *param, const libcec_configuration &) { return 0; }
static int CBCecAlert(void *param, const libcec_alert, const libcec_parameter &) { return 0; }
static int CBCecMenuStateChanged(void *param, const cec_menu_state) { return 0; }
static void CBCecSourceActivated(void *param, const cec_logical_address, const uint8_t) {}

@implementation DKCECController

-(id)init {
	
	self = [super init];
	
	if (self) {
		
		// Insert code here to initialize your application
		libcec_configuration config;
		memset(&config, 0, sizeof(config));
		
		int retCode = cec_initialise(&config);
		if (retCode == 0)
			NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"CEC init failed");
		
		const char * info = cec_get_lib_info();
		if (info != NULL)
			NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [NSString stringWithUTF8String:info]);
		
		ICECCallbacks callbacks;
		memset(&callbacks, 0, sizeof(ICECCallbacks));
		
		callbacks.CBCecKeyPress = CBCecKeyPress;
		callbacks.CBCecCommand = CBCecCommand;
		callbacks.CBCecConfigurationChanged = CBCecConfigurationChanged;
		callbacks.CBCecAlert = CBCecAlert;
		callbacks.CBCecMenuStateChanged = CBCecMenuStateChanged;
		callbacks.CBCecSourceActivated = CBCecSourceActivated;
		
		retCode = cec_enable_callbacks((__bridge void *)self, &callbacks);
		if (retCode < 1)
			NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"CEC callbacks failed");
		
	}
	
	return self;
}

@end
