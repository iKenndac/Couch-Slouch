//
//  DKCECController.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKCECController.h"
#import "cecc.h"

static NSTimeInterval const kDevicePollInterval = 2.0;
static NSTimeInterval const kDevicePingInterval = 10.0;

#define DK_WITH_DEBUG_LOGGING YES

@interface DKCECController ()

@property (nonatomic, readwrite) cec_menu_state menuState;
@property (nonatomic, readwrite) libcec_configuration configuration;
@property (nonatomic, readwrite) BOOL hasConnection;
@property (nonatomic, readwrite) NSTimer *pollTimer;
@property (nonatomic, readwrite) NSTimer *pingTimer;

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
	return [self initWithDeviceName:nil];
}

-(id)initWithDeviceName:(NSString *)name  {
	
	self = [super init];
	
	if (self) {

		if (name.length == 0)
			name = [[NSProcessInfo processInfo] hostName];

		cec_device_type_list list;
		memset(&list, 0, sizeof(cec_device_type_list));
		list.types[0] = CEC_DEVICE_TYPE_PLAYBACK_DEVICE;
		list.types[1] = CEC_DEVICE_TYPE_RESERVED;
		list.types[2] = CEC_DEVICE_TYPE_RESERVED;
		list.types[3] = CEC_DEVICE_TYPE_RESERVED;
		list.types[4] = CEC_DEVICE_TYPE_RESERVED;

		int retCode = cec_init_typed([name UTF8String], list);
		if (retCode < 1) {
			if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"CEC init failed");
			return nil;
		}

		ICECCallbacks callbacks;
		memset(&callbacks, 0, sizeof(ICECCallbacks));
		
		callbacks.CBCecKeyPress = CBCecKeyPress;
		callbacks.CBCecCommand = CBCecCommand;
		callbacks.CBCecConfigurationChanged = CBCecConfigurationChanged;
		callbacks.CBCecAlert = CBCecAlert;
		callbacks.CBCecMenuStateChanged = CBCecMenuStateChanged;
		callbacks.CBCecSourceActivated = CBCecSourceActivated;
		
		retCode = cec_enable_callbacks((__bridge void *)self, &callbacks);
		if (retCode < 1) {
			if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"CEC callbacks failed");
			return nil;
		}

		[self checkForDevices:nil];
		if (self.hasConnection)
			[self startDevicePinging];
		else
			[self startDevicePolling];
	}
	
	return self;
}

-(void)dealloc {
	[self stopDevicePolling];
	[self stopDevicePinging];
	cec_close();
	cec_destroy();
}

#pragma mark - Device Detection

-(void)startDevicePolling {

	[self stopDevicePolling];
	self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:kDevicePollInterval
													  target:self
													selector:@selector(checkForDevices:)
													userInfo:nil
													 repeats:YES];

}

-(void)stopDevicePolling {
	[self.pollTimer invalidate];
	self.pollTimer = nil;
}

-(void)checkForDevices:(NSTimer *)timer {

	cec_adapter deviceList;
	memset(&deviceList, 0, sizeof(cec_adapter));
	int retCode = cec_find_adapters(&deviceList, 1, NULL);

	if (retCode < 0) {
		if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: Failed with %u", NSStringFromClass([self class]), NSStringFromSelector(_cmd), retCode);
	} else if (retCode > 0) {

		retCode = cec_open(deviceList.path, CEC_DEFAULT_CONNECT_TIMEOUT);
		if (retCode > 0) {
			self.hasConnection = YES;
			[self stopDevicePolling];
			[self startDevicePinging];
		}
	} else {
		if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"No devices found.");
	}
}

-(void)startDevicePinging {
	
	[self stopDevicePinging];
	self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:kDevicePingInterval
													  target:self
													selector:@selector(pingDevice:)
													userInfo:nil
													 repeats:YES];
}

-(void)stopDevicePinging {
	[self.pingTimer invalidate];
	self.pingTimer = nil;
}

-(void)pingDevice:(NSTimer *)timer {

	if (!self.hasConnection) return;
	int retCode = cec_ping_adapters();
	if (retCode == 1) return;

	if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Connection lost.");
	cec_close();
	self.hasConnection = NO;

	[self stopDevicePinging];
	[self startDevicePolling];
}

#pragma mark - Device Control

-(BOOL)transmitCommand:(cec_command)command {
	if (!self.hasConnection) return NO;
	return (BOOL)cec_transmit(&command);
}

-(BOOL)sendPowerOnToDevice:(cec_logical_address)address {
	if (!self.hasConnection) return NO;
	return (BOOL)cec_power_on_devices(address);
}

-(BOOL)sendPowerOffToDevice:(cec_logical_address)address {
	if (!self.hasConnection) return NO;
	return (BOOL)cec_standby_devices(address);
}

-(cec_power_status)powerStatusOfDevice:(cec_logical_address)device {
	if (!self.hasConnection) return CEC_POWER_STATUS_UNKNOWN;
	return cec_get_device_power_status(device);
}

-(cec_logical_addresses)activeDevicesOnHDMIBus {
	if (!self.hasConnection) {
		cec_logical_addresses nothing;
		memset(&nothing, 0, sizeof(cec_logical_address));
		nothing.primary = CECDEVICE_UNKNOWN;
		return nothing;
	}

	return cec_get_active_devices();
}

-(cec_logical_addresses)localDevices {
	if (!self.hasConnection) {
		cec_logical_addresses nothing;
		memset(&nothing, 0, sizeof(cec_logical_address));
		nothing.primary = CECDEVICE_UNKNOWN;
		return nothing;
	}

	return cec_get_logical_addresses();
}

-(BOOL)hasDeviceOfType:(cec_device_type)wantedDevice {
	if (!self.hasConnection) return NO;
	return (BOOL)cec_is_active_device_type(wantedDevice);
}

-(BOOL)hasDevice:(cec_logical_address)device {
	if (!self.hasConnection) return NO;
	return (BOOL)cec_is_active_device(device);
}

-(cec_logical_address)sourceDevice {
	if (!self.hasConnection) return CECDEVICE_UNKNOWN;
	return cec_get_active_source();
}

-(BOOL)deviceIsSource:(cec_logical_address)device {
	if (!self.hasConnection) return NO;
	return (BOOL)cec_is_active_source(device);
}

-(BOOL)isSource {
	if (!self.hasConnection) return NO;
	return (BOOL)cec_is_libcec_active_source();
}

@end
