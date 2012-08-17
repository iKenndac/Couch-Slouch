//
//  DKCECController.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKCECController.h"
#import "cecc.h"

@interface DKCECController ()

@property (nonatomic, readwrite) cec_menu_state menuState;
@property (nonatomic, readwrite) libcec_configuration configuration;

@end

// ------------- Callbacks ------------------

static int CBCecLogMessage(void *param, const cec_log_message message) {

	DKCECController *controller = (__bridge DKCECController *)param;
	if ([controller.delegate respondsToSelector:@selector(cecController:didLogMessage:ofSeverity:)])
		[controller.delegate cecController:controller
							 didLogMessage:[NSString stringWithUTF8String:message.message]
								ofSeverity:message.level];
	return 1;
}

static int CBCecKeyPress(void *param, const cec_keypress keyPress) {

	DKCECController *controller = (__bridge DKCECController *)param;
	if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveKeyPress:)])
		[controller.delegate cecController:controller
						didReceiveKeyPress:keyPress];
	return 1;
}


static int CBCecCommand(void *param, const cec_command command) {

	DKCECController *controller = (__bridge DKCECController *)param;
	if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveCommand:)])
		[controller.delegate cecController:controller
						 didReceiveCommand:command];
	return 1;
}

static int CBCecConfigurationChanged(void *param, const libcec_configuration config) {

	DKCECController *controller = (__bridge DKCECController *)param;
	controller.configuration = config;
	return 1;
}

static int CBCecAlert(void *param, const libcec_alert alert, const libcec_parameter parameter) {

	DKCECController *controller = (__bridge DKCECController *)param;
	if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveAlert:forParamter:)])
		[controller.delegate cecController:controller
						   didReceiveAlert:alert
							   forParamter:parameter];
	return 1;
}

static int CBCecMenuStateChanged(void *param, const cec_menu_state menuState) {

	DKCECController *controller = (__bridge DKCECController *)param;
	controller.menuState = menuState;
	return 1;
}

static void CBCecSourceActivated(void *param, const cec_logical_address logicalAddress, const uint8_t isActivated) {

	DKCECController *controller = (__bridge DKCECController *)param;
	if ([controller.delegate respondsToSelector:@selector(cecController:activationDidChangeForLogicalDevice:toState:)])
		[controller.delegate cecController:controller
	   activationDidChangeForLogicalDevice:logicalAddress
								   toState:(BOOL)isActivated];
}



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
