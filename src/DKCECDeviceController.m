//
//  DKCECController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 16/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKCECDeviceController.h"
#import "cecc.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Constants.h"

static NSTimeInterval const kDevicePollInterval = 2.0;
static NSTimeInterval const kDevicePingInterval = 30.0;

#define DK_WITH_DEBUG_LOGGING YES

@interface DKCECDeviceController ()

@property (nonatomic, readwrite) cec_menu_state menuState;
@property (nonatomic, readwrite) BOOL hasConnectionToDevice;
@property (nonatomic, readwrite) BOOL hasAccessibilityPermission;
@property (nonatomic, readwrite) NSTimer *pollTimer;
@property (nonatomic, readwrite) NSTimer *pingTimer;
@property (nonatomic, readwrite) BOOL isActiveSource;
@property (nonatomic, readwrite) BOOL isTVOn;
@property (nonatomic, readwrite) NSMutableDictionary *keyPressStorage;

-(void)_didReceiveNewConfiguration:(const libcec_configuration)config;
-(void)handleKeyPress:(cec_keypress)press;

@end

// ------------- Callbacks ------------------

static void DKCBCecLogMessage(void *param, const cec_log_message* message) {
    NSString *messageString = [NSString stringWithUTF8String:message->message];
    cec_log_level messageSeverity = message->level;

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		if ([controller.delegate respondsToSelector:@selector(cecController:didLogMessage:ofSeverity:)])
            [controller.delegate cecController:controller didLogMessage:messageString ofSeverity:messageSeverity];
	});
}

static void DKCBCecKeyPress(void *param, const cec_keypress* keyPress) {
    cec_keypress localKeyPress;
    memcpy(&localKeyPress, keyPress, sizeof(localKeyPress));

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		[controller handleKeyPress:localKeyPress];
	});
}


static void DKCBCecCommand(void *param, const cec_command* command) {
    cec_command localCommand;
    memcpy(&localCommand, command, sizeof(localCommand));

	DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;

	if (localCommand.initiator == CECDEVICE_TV && localCommand.destination == CECDEVICE_BROADCAST) {
		// TV is telling us important information!
		if (localCommand.opcode == CEC_OPCODE_STANDBY) {
			dispatch_async(dispatch_get_main_queue(), ^{
				controller.isTVOn = NO;
				controller.isActiveSource = NO;
			});
		}

		if (localCommand.opcode == CEC_OPCODE_ACTIVE_SOURCE) {
            if (localCommand.parameters.size < 2) {
				return;
            }
			
			uint16_t iAddress = ((uint16_t)localCommand.parameters.data[0] << 8) | ((uint16_t)localCommand.parameters.data[1]);

			dispatch_async(dispatch_get_main_queue(), ^{
				controller.isTVOn = YES;
				controller.isActiveSource = (iAddress == controller.configuration->iPhysicalAddress);
			});
		}

		if (localCommand.opcode == CEC_OPCODE_SET_STREAM_PATH) {
            if (localCommand.parameters.size < 2) {
                return;
            }
			
			uint16_t iStreamAddress = ((uint16_t)localCommand.parameters.data[0] << 8) | ((uint16_t)localCommand.parameters.data[1]);

			dispatch_async(dispatch_get_main_queue(), ^{
				controller.isTVOn = YES;
				controller.isActiveSource = (iStreamAddress == controller.configuration->iPhysicalAddress);
			});
		}

		if (localCommand.opcode == CEC_OPCODE_ROUTING_CHANGE) {

            if (localCommand.parameters.size < 4) {
				return;
            }

			uint16_t iNewAddress = ((uint16_t)localCommand.parameters.data[2] << 8) | ((uint16_t)localCommand.parameters.data[3]);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				controller.isTVOn = YES;
				controller.isActiveSource = (iNewAddress == controller.configuration->iPhysicalAddress);
			});
		}
	}

	dispatch_async(dispatch_get_main_queue(), ^{
        if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveCommand:)]) {
            [controller.delegate cecController:controller didReceiveCommand:localCommand];
        }
	});
}

static void DKCBCecConfigurationChanged(void *param, const libcec_configuration* config) {
    libcec_configuration localConfiguration;
    memcpy(&localConfiguration, config, sizeof(localConfiguration));

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		[controller _didReceiveNewConfiguration:localConfiguration];
	});
}

static void DKCBCecAlert(void *param, const libcec_alert alert, const libcec_parameter parameter) {

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		if ([controller.delegate respondsToSelector:@selector(cecController:didReceiveAlert:forParamter:)])
			[controller.delegate cecController:controller
							   didReceiveAlert:alert
								   forParamter:parameter];
	});
}

static int DKCBCecMenuStateChanged(void *param, const cec_menu_state menuState) {

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		controller.menuState = menuState;
	});
	return 1;
}

static void DKCBCecSourceActivated(void *param, const cec_logical_address logicalAddress, const uint8_t isActivated) {

	BOOL isActive = (isActivated == 1);

	dispatch_async(dispatch_get_main_queue(), ^{
		DKCECDeviceController *controller = (__bridge DKCECDeviceController *)param;
		controller.isActiveSource = isActive;

		if ([controller.delegate respondsToSelector:@selector(cecController:activationDidChangeForLogicalDevice:toState:)])
			[controller.delegate cecController:controller
		   activationDidChangeForLogicalDevice:logicalAddress
									   toState:isActive];
	});
}

static ICECCallbacks callbacks;

@implementation DKCECDeviceController {
	libcec_configuration *cec_configuration;
    libcec_connection_t connection;
}

static dispatch_queue_t cec_global_queue;

+(void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cec_global_queue = dispatch_queue_create("org.danielkennett.CECController", DISPATCH_QUEUE_SERIAL);
	});

	memset(&callbacks, 0, sizeof(ICECCallbacks));
	callbacks.keyPress = &DKCBCecKeyPress;
	callbacks.commandReceived = &DKCBCecCommand;
	callbacks.configurationChanged = &DKCBCecConfigurationChanged;
	callbacks.alert = &DKCBCecAlert;
	callbacks.menuStateChanged = &DKCBCecMenuStateChanged;
	callbacks.sourceActivated = &DKCBCecSourceActivated;
	callbacks.logMessage = &DKCBCecLogMessage;
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

		self.keyPressStorage = [NSMutableDictionary new];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		if (name.length == 0)
			name = (__bridge_transfer NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);

		cec_device_type_list list;
		memset(&list, 0, sizeof(cec_device_type_list));
		list.types[0] = CEC_DEVICE_TYPE_RECORDING_DEVICE;
		list.types[1] = CEC_DEVICE_TYPE_RESERVED;
		list.types[2] = CEC_DEVICE_TYPE_RESERVED;
		list.types[3] = CEC_DEVICE_TYPE_RESERVED;
		list.types[4] = CEC_DEVICE_TYPE_RESERVED;

		cec_configuration = malloc(sizeof(libcec_configuration));
		memset(cec_configuration, 0, sizeof(libcec_configuration));
		snprintf(cec_configuration->strDeviceName, 13, "%s", [name UTF8String]);
		cec_configuration->deviceTypes = list;
        cec_configuration->clientVersion = LIBCEC_VERSION_CURRENT;

		if ([defaults valueForKey:kPhysicalAddressUserDefaultsKey] != nil)
			cec_configuration->iPhysicalAddress = (uint16_t)[[defaults valueForKey:kPhysicalAddressUserDefaultsKey] unsignedIntValue];
		else
			cec_configuration->iPhysicalAddress = CEC_INVALID_PHYSICAL_ADDRESS;

		connection = libcec_initialise(cec_configuration);
        if (connection == NULL) {
            if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"CEC init failed");
            return nil;
        }

        int retCode = libcec_enable_callbacks(connection, (__bridge void *)self, &callbacks);
		if (retCode < 1) {
			if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"CEC callbacks failed");
			return nil;
		}

        [self refreshPermissions];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                     name:NSApplicationDidBecomeActiveNotification object:nil];
	}
	
	return self;
}

-(libcec_configuration *)configuration {
	return cec_configuration;
}

+(NSSet *)keyPathsForValuesAffectingHumanReadableStatus {
	return [NSSet setWithObjects:@"hasConnection", @"isActiveSource", nil];
}

-(NSString *)humanReadableStatus {
    if (!self.hasAccessibilityPermission)
        return NSLocalizedString(@"no accessibility permission title", @"");
    else if (!self.hasConnectionToDevice)
		return NSLocalizedString(@"no connection title", @"");
    else if (!self.isActiveSource)
		return NSLocalizedString(@"connected but not active source title", @"");
	else
		return NSLocalizedString(@"active source title", @"");
}

+(NSSet *)keyPathsForValuesAffectingShortHumanReadableStatus {
	return [NSSet setWithObject:@"humanReadableStatus"];
}

-(NSString *)shortHumanReadableStatus {
    if (!self.hasAccessibilityPermission)
        return NSLocalizedString(@"short no accessibility permission title", @"");
    else if (!self.hasConnectionToDevice)
        return NSLocalizedString(@"short no connection title", @"");
    else if (!self.isActiveSource)
		return NSLocalizedString(@"short connected but not active source title", @"");
	else
		return NSLocalizedString(@"short active source title", @"");
}

+(NSSet *)keyPathsForValuesAffectingStatusImage {
	return [NSSet setWithObjects:@"hasConnection", @"isActiveSource", nil];
}

-(NSImage *)statusImage {
	
	if (!self.hasConnectionToDevice)
		return [NSImage imageNamed:@"lamp-red"];
	else if (!self.isActiveSource)
		return [NSImage imageNamed:@"lamp-yellow"];
	else
		return [NSImage imageNamed:@"lamp-green"];
}

+(NSSet *)keyPathsForValuesAffectingPhysicalAddressDisplayString {
	return [NSSet setWithObject:@"configuration"];
}

-(NSString *)physicalAddressDisplayString {

	uint16_t address = [[NSUserDefaults standardUserDefaults] integerForKey:kPhysicalAddressUserDefaultsKey];
	uint16_t topPort = (address >> 12) & 0xF;
	uint16_t secondPort = (address >> 8) & 0xF;

	if (secondPort == 0 && topPort > 0)
		return [NSString stringWithFormat:NSLocalizedString(@"direct connect status formatter", @""), @(topPort)];
	else if (secondPort != 0)
		return [NSString stringWithFormat:NSLocalizedString(@"av connect status formatter", @""), @(secondPort), @(topPort)];
	else
		return NSLocalizedString(@"unknown connect status", @"");
}

-(void)dealloc {
	[self stopDevicePolling];
	[self stopDevicePinging];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:nil];

	free(cec_configuration);
	cec_configuration = NULL;

    libcec_connection_t this_connection = connection;
    connection = NULL;

	dispatch_async([DKCECDeviceController cecQueue], ^{
        libcec_destroy(this_connection);
	});
}

-(void)_didReceiveNewConfiguration:(const libcec_configuration)config {
	[self willChangeValueForKey:@"configuration"];
	if (cec_configuration != NULL)
		memcpy(cec_configuration, &config, sizeof(libcec_configuration));
	[self didChangeValueForKey:@"configuration"];
}

-(void)handleKeyPress:(cec_keypress)press {

	BOOL isUp = (press.duration > 0);
	BOOL needsFakeDown = isUp && self.keyPressStorage[@(press.keycode)] == nil;

	if (!isUp || needsFakeDown) {

		cec_keypress downPress;
		memset(&downPress, 0, sizeof(cec_keypress));

		if (needsFakeDown) {
			downPress.keycode = press.keycode;
			downPress.duration = 0;
		} else {
			downPress = press;
		}

		if ([self.delegate respondsToSelector:@selector(cecController:didReceiveKeyDown:)])
			[self.delegate cecController:self didReceiveKeyDown:downPress];

		self.keyPressStorage[@(press.keycode)] = @(press.keycode);
	}

	if (isUp) {
		if ([self.delegate respondsToSelector:@selector(cecController:didReceiveKeyUp:)])
			[self.delegate cecController:self didReceiveKeyUp:press];

		[self.keyPressStorage removeObjectForKey:@(press.keycode)];
	}
}

#pragma mark - Local Permissions

-(void)applicationDidBecomeActive:(NSNotification *)notification {
    [self refreshPermissions];
}

-(void)refreshPermissions {
    self.hasAccessibilityPermission = AXIsProcessTrusted();
}

#pragma mark - Device Detection


// Disconnect from the CEC device.
-(void)close:(void (^)(BOOL success))block {
    
    if (!self.hasConnectionToDevice) {
        if (block) block(YES);
        return;
    }
    
    self.hasConnectionToDevice = NO;
    [self stopDevicePinging];
    
	dispatch_async([DKCECDeviceController cecQueue], ^{
        libcec_close(self->connection);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(YES);
        });
    });
    
}

// Search and connect to the CEC device.
-(void)open:(void (^)(BOOL success))block {
    
    if (self.hasConnectionToDevice) {
        if (block) block(YES);
        return;
    }

	[self findDeviceAndConnect:^{
		if (self.hasConnectionToDevice)
			[self startDevicePinging];
		else
			[self startDevicePolling];

		if (block) block(YES);
	}];

}

-(void)startDevicePolling {

	[self stopDevicePolling];
	self.pollTimer = [NSTimer timerWithTimeInterval:kDevicePollInterval
											 target:self
										   selector:@selector(checkForDevices:)
										   userInfo:nil
											repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:self.pollTimer forMode:NSRunLoopCommonModes];
}

-(void)stopDevicePolling {
	[self.pollTimer invalidate];
	self.pollTimer = nil;
}

-(void)checkForDevices:(NSTimer *)timer {
	[self findDeviceAndConnect:nil];
}

-(void)findDeviceAndConnect:(dispatch_block_t)block {

	if (self.hasConnectionToDevice) {
		if (block) block();
		return;
	}

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_adapter deviceList;
		memset(&deviceList, 0, sizeof(cec_adapter));
		int retCode = libcec_find_adapters(self->connection, &deviceList, 1, NULL);

		if (retCode < 0) {
			if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: Failed with %u", NSStringFromClass([self class]), NSStringFromSelector(_cmd), retCode);
		} else if (retCode > 0) {

			retCode = libcec_open(self->connection, deviceList.path, CEC_DEFAULT_CONNECT_TIMEOUT);
			if (retCode > 0) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Found device.");
					self.hasConnectionToDevice = YES;
					[self stopDevicePolling];
					[self startDevicePinging];
					if (block) block();
				});
				return;
			}
		}

		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(); });

	});

}

-(void)startDevicePinging {
	
	[self stopDevicePinging];
	self.pingTimer = [NSTimer timerWithTimeInterval:kDevicePingInterval
													  target:self
													selector:@selector(pingDevice:)
													userInfo:nil
													 repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
}

-(void)stopDevicePinging {
	[self.pingTimer invalidate];
	self.pingTimer = nil;
}

-(void)pingDevice:(NSTimer *)timer {

	if (!self.hasConnectionToDevice) return;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		
		int retCode = libcec_ping_adapters(self->connection);
		if (retCode == 1) return;
		
		if (DK_WITH_DEBUG_LOGGING) NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Connection lost.");
		libcec_close(self->connection);

		dispatch_async(dispatch_get_main_queue(), ^{
			self.hasConnectionToDevice = NO;
			[self stopDevicePinging];
			[self startDevicePolling];
		});
	});
}

#pragma mark - Device Control

-(void)activateSource:(void (^)(BOOL success))block {

	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_activate_source(self->connection, 0);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)sendRawCommand:(cec_command)command completion:(void (^)(BOOL success))block {

	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_transmit(self->connection, &command);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)sendPowerOnToDevice:(cec_logical_address)address completion:(void (^)(BOOL success))block {

	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_power_on_devices(self->connection, address);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)sendPowerOffToDevice:(cec_logical_address)address completion:(void (^)(BOOL success))block {

	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_standby_devices(self->connection, address);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestPowerStatusOfDevice:(cec_logical_address)device completion:(void (^)(cec_power_status status))block {

	if (!self.hasConnectionToDevice) {
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(CEC_POWER_STATUS_UNKNOWN); });
		return;
	}
	
	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_power_status status = libcec_get_device_power_status(self->connection, device);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(status); });
	});
}

-(void)requestActiveDevicesOnHDMIBus:(void (^)(cec_logical_addresses devices))block {
	
	if (!self.hasConnectionToDevice) {
		cec_logical_addresses nothing;
		memset(&nothing, 0, sizeof(cec_logical_address));
		nothing.primary = CECDEVICE_UNKNOWN;
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(nothing); });
		return;
	}

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_logical_addresses devices = libcec_get_active_devices(self->connection);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(devices); });
	});
}

-(void)requestLocalDevices:(void (^)(cec_logical_addresses devices))block {
	
	if (!self.hasConnectionToDevice) {
		cec_logical_addresses nothing;
		memset(&nothing, 0, sizeof(cec_logical_address));
		nothing.primary = CECDEVICE_UNKNOWN;
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(nothing); });
		return;
	}

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_logical_addresses devices = libcec_get_logical_addresses(self->connection);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(devices); });
	});
}

-(void)requestIfAvailableDeviceOfType:(cec_device_type)wantedDevice completion:(void (^)(BOOL hasDeviceType))block {
	
	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_is_active_device_type(self->connection, wantedDevice);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestIfAvailableDevice:(cec_logical_address)device completion:(void (^)(BOOL hasDevice))block{

	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_is_active_device(self->connection, device);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestSourceDevice:(void (^)(cec_logical_address sourceDevice))block {

	if (!self.hasConnectionToDevice) {
		if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(CECDEVICE_UNKNOWN); });
		return;
	}

	dispatch_async([DKCECDeviceController cecQueue], ^{
		cec_logical_address device = libcec_get_active_source(self->connection);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(device); });
	});
}

-(void)requestIfDeviceIsSource:(cec_logical_address)device completion:(void (^)(BOOL isSource))block {

	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_is_active_source(self->connection, device);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)requestIfLocalIsSource:(void (^)(BOOL isSource))block {

	__block BOOL success = self.hasConnectionToDevice;

	dispatch_async([DKCECDeviceController cecQueue], ^{
		if (success) success = (BOOL)libcec_is_libcec_active_source(self->connection);
		dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(success); });
	});
}

-(void)updatePhysicalAddress:(uint16_t)address completion:(void (^)(BOOL success))block {

	[self willChangeValueForKey:@"physicalAddressDisplayString"];
	[[NSUserDefaults standardUserDefaults] setInteger:address forKey:kPhysicalAddressUserDefaultsKey];
	[self didChangeValueForKey:@"physicalAddressDisplayString"];

	dispatch_async([DKCECDeviceController cecQueue], ^{
		BOOL success = (libcec_set_physical_address(self->connection, address) == 1);
		dispatch_async(dispatch_get_main_queue(), ^{
			if (block) block(success);
		});
	});
}

@end
