//
//  DKCECController.m
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKCECDeviceController.h"
#import "cecc.h"
#import <SystemConfiguration/SystemConfiguration.h>

static NSTimeInterval const kDevicePollInterval = 2.0;
static NSTimeInterval const kDevicePingInterval = 10.0;

#define DK_WITH_DEBUG_LOGGING YES

@interface DKCECDeviceController ()

@property (nonatomic, readwrite) cec_menu_state menuState;
@property (nonatomic, readwrite) libcec_configuration configuration;
@property (nonatomic, readwrite) BOOL hasConnection;
@property (nonatomic, readwrite) NSTimer *pollTimer;
@property (nonatomic, readwrite) NSTimer *pingTimer;
@property (nonatomic, readwrite) BOOL isActiveSource;

@end

// ------------- Callbacks ------------------

static int DKCBCecLogMessage(void *param, const cec_log_message message) {

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		if ([controller.delegate respondsToSelector:@selector(cecController:didLogMessage:ofSeverity:)])
			[controller.delegate cecController:controller
								 didLogMessage:[NSString stringWithUTF8String:message.message]
									ofSeverity:message.level];
	});
	return 1;
}

static int DKCBCecKeyPress(void *param, const cec_keypress keyPress) {

	dispatch_async(dispatch_get_main_queue(), ^{
	DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
	if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveKeyPress:)])
		[controller.delegate cecController:controller
						didReceiveKeyPress:keyPress];
	});
	return 1;
}


static int DKCBCecCommand(void *param, const cec_command command) {

	dispatch_async(dispatch_get_main_queue(), ^{
	DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
	if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveCommand:)])
		[controller.delegate cecController:controller
						 didReceiveCommand:command];
	});
	return 1;
}

static int DKCBCecConfigurationChanged(void *param, const libcec_configuration config) {

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		controller.configuration = config;
	});
	return 1;
}

static int DKCBCecAlert(void *param, const libcec_alert alert, const libcec_parameter parameter) {

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveAlert:forParamter:)])
			[controller.delegate cecController:controller
							   didReceiveAlert:alert
								   forParamter:parameter];
	});
	return 1;
}

static int DKCBCecMenuStateChanged(void *param, const cec_menu_state menuState) {

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		controller.menuState = menuState;
	});
	return 1;
}

static void DKCBCecSourceActivated(void *param, const cec_logical_address logicalAddress, const uint8_t isActivated) {

	BOOL isActive = cec_is_libcec_active_source();

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		controller.isActiveSource = isActive;

		if ([controller.delegate respondsToSelector:@selector(cecController:activationDidChangeForLogicalDevice:toState:)])
			[controller.delegate cecController:controller
		   activationDidChangeForLogicalDevice:logicalAddress
									   toState:(BOOL)isActivated];
	});
}

static ICECCallbacks callbacks;

@implementation DKCECDeviceController

static dispatch_queue_t cec_global_queue;

+(void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cec_global_queue = dispatch_queue_create("org.danielkennett.CECController", DISPATCH_QUEUE_SERIAL);
	});

	memset(&callbacks, 0, sizeof(ICECCallbacks));
	callbacks.CBCecKeyPress = &DKCBCecKeyPress;
	callbacks.CBCecCommand = &DKCBCecCommand;
	callbacks.CBCecConfigurationChanged = &DKCBCecConfigurationChanged;
	callbacks.CBCecAlert = &DKCBCecAlert;
	callbacks.CBCecMenuStateChanged = &DKCBCecMenuStateChanged;
	callbacks.CBCecSourceActivated = &DKCBCecSourceActivated;
	callbacks.CBCecLogMessage = &DKCBCecLogMessage;
}

+(dispatch_queue_t)cecQueue {
	return cec_global_queue;
}

-(id)init {
	return [self initWithDeviceName:nil];
}

-(id)initWithDeviceName:(NSString *)name  {
	
	self = [super init];
	
	if (self) {

		if (name.length == 0)
			name = (__bridge_transfer NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);

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

+(NSSet *)keyPathsForValuesAffectingHumanReadableStatus {
	return [NSSet setWithObjects:@"hasConnection", @"isActiveSource", nil];
}

-(NSString *)humanReadableStatus {

	if (!self.hasConnection)
		return NSLocalizedString(@"no connection title", @"");
	else if (!self.isActiveSource)
		return NSLocalizedString(@"connected but not active source title", @"");
	else
		return NSLocalizedString(@"active source title", @"");
}

-(void)dealloc {
	[self stopDevicePolling];
	[self stopDevicePinging];

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_close();
		cec_destroy();
	});
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

	if (self.hasConnection) return;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_adapter deviceList;
		memset(&deviceList, 0, sizeof(cec_adapter));
		int retCode = cec_find_adapters(&deviceList, 1, NULL);

		if (retCode < 0) {
			if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: Failed with %u", NSStringFromClass([self class]), NSStringFromSelector(_cmd), retCode);
		} else if (retCode > 0) {

			retCode = cec_open(deviceList.path, CEC_DEFAULT_CONNECT_TIMEOUT);
			if (retCode > 0) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Found device.");
					self.hasConnection = YES;
					[self stopDevicePolling];
					[self startDevicePinging];
				});
			}
		}
	});
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

	dispatch_async([DKCECDeviceController cecQueue], ^{
		
		int retCode = cec_ping_adapters();
		if (retCode == 1) {
			if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Adapter ping successful.");
			return;
		}

		if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Connection lost.");
		cec_close();

		dispatch_async(dispatch_get_main_queue(), ^{
			self.hasConnection = NO;
			[self stopDevicePinging];
			[self startDevicePolling];
		});
	});
}

#pragma mark - Device Control

-(void)sendRawCommand:(cec_command)command completion:(void (^)(BOOL success))block {

	__block BOOL success = self.hasConnection;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)cec_transmit(&command);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)sendPowerOnToDevice:(cec_logical_address)address completion:(void (^)(BOOL success))block {

	__block BOOL success = self.hasConnection;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)cec_power_on_devices(address);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)sendPowerOffToDevice:(cec_logical_address)address completion:(void (^)(BOOL success))block {

	__block BOOL success = self.hasConnection;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)cec_standby_devices(address);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestPowerStatusOfDevice:(cec_logical_address)device completion:(void (^)(cec_power_status status))block {

	if (!self.hasConnection) {
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(CEC_POWER_STATUS_UNKNOWN); });
		return;
	}
	
	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_power_status status = cec_get_device_power_status(device);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(status); });
	});
}

-(void)requestActiveDevicesOnHDMIBus:(void (^)(cec_logical_addresses devices))block {
	
	if (!self.hasConnection) {
		cec_logical_addresses nothing;
		memset(&nothing, 0, sizeof(cec_logical_address));
		nothing.primary = CECDEVICE_UNKNOWN;
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(nothing); });
		return;
	}

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_logical_addresses devices = cec_get_active_devices();
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(devices); });
	});
}

-(void)requestLocalDevices:(void (^)(cec_logical_addresses devices))block {
	
	if (!self.hasConnection) {
		cec_logical_addresses nothing;
		memset(&nothing, 0, sizeof(cec_logical_address));
		nothing.primary = CECDEVICE_UNKNOWN;
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(nothing); });
		return;
	}

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_logical_addresses devices = cec_get_logical_addresses();
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(devices); });
	});
}

-(void)requestIfAvailableDeviceOfType:(cec_device_type)wantedDevice completion:(void (^)(BOOL hasDeviceType))block {
	
	__block BOOL success = self.hasConnection;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)cec_is_active_device_type(wantedDevice);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestIfAvailableDevice:(cec_logical_address)device completion:(void (^)(BOOL hasDevice))block{

	__block BOOL success = self.hasConnection;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)cec_is_active_device(device);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestSourceDevice:(void (^)(cec_logical_address sourceDevice))block {

	if (!self.hasConnection) {
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(CECDEVICE_UNKNOWN); });
		return;
	}

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_logical_address device = cec_get_active_source();
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(device); });
	});
}

-(void)requestIfDeviceIsSource:(cec_logical_address)device completion:(void (^)(BOOL isSource))block {

	__block BOOL success = self.hasConnection;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)cec_is_active_source(device);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestIfLocalIsSource:(void (^)(BOOL isSource))block {

	__block BOOL success = self.hasConnection;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)cec_is_libcec_active_source();
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

@end
