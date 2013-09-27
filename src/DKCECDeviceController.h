//
//  DKCECController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 16/08/2012.
//  For license information, see LICENSE.markdown
//

#import <Foundation/Foundation.h>
#import "cectypes.h"

@class DKCECDeviceController;

@protocol DKCECDeviceControllerDelegate <NSObject>
@optional

-(void)cecController:(DKCECDeviceController *)controller didLogMessage:(NSString *)message ofSeverity:(cec_log_level)logLevel;
-(void)cecController:(DKCECDeviceController *)controller didReceiveKeyPress:(cec_keypress)keyPress;
-(void)cecController:(DKCECDeviceController *)controller didReceiveCommand:(cec_command)command;
-(void)cecController:(DKCECDeviceController *)controller didReceiveAlert:(libcec_alert)alert forParamter:(libcec_parameter)parameter;
-(void)cecController:(DKCECDeviceController *)controller activationDidChangeForLogicalDevice:(cec_logical_address)device toState:(BOOL)activated;

@end

@interface DKCECDeviceController : NSObject

-(id)initWithDeviceName:(NSString *)name;

@property (nonatomic, readonly) cec_menu_state menuState;
@property (nonatomic, readonly) libcec_configuration *configuration;
@property (nonatomic, readwrite, weak) id <DKCECDeviceControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL hasConnection;
@property (nonatomic, readonly, copy) NSString *humanReadableStatus;
@property (nonatomic, readonly, copy) NSString *shortHumanReadableStatus;
@property (nonatomic, readonly) NSImage *statusImage;
@property (nonatomic, readonly) BOOL isTVOn;
@property (nonatomic, readonly) BOOL isActiveSource;
@property (nonatomic, readonly) NSString *physicalAddressDisplayString;

// ----

// Transmit a raw command the the local connected device.
-(void)sendRawCommand:(cec_command)command completion:(void (^)(BOOL success))block;

// Send a power on command to the given device.
-(void)sendPowerOnToDevice:(cec_logical_address)address completion:(void (^)(BOOL success))block;

// Send a standby command to the given device.
-(void)sendPowerOffToDevice:(cec_logical_address)address completion:(void (^)(BOOL success))block;

// Get the power status of the given device
-(void)requestPowerStatusOfDevice:(cec_logical_address)device completion:(void (^)(cec_power_status status))block;

// Get the devices available on the HDMI bus, not including the local connected device.
-(void)requestActiveDevicesOnHDMIBus:(void (^)(cec_logical_addresses devices))block;

// Get the local connected device address(es)
-(void)requestLocalDevices:(void (^)(cec_logical_addresses devices))block;

// Returns YES if the given device type is present on the bus.
-(void)requestIfAvailableDeviceOfType:(cec_device_type)wantedDevice completion:(void (^)(BOOL hasDeviceType))block;

// Returns YES when the given device is present on the bus.
-(void)requestIfAvailableDevice:(cec_logical_address)device completion:(void (^)(BOOL hasDevice))block;

// Returns the device that is the current source (i.e., being presented on the TV)
-(void)requestSourceDevice:(void (^)(cec_logical_address sourceDevice))block;

// Returns YES if the given device is being presented on the TV
-(void)requestIfDeviceIsSource:(cec_logical_address)device completion:(void (^)(BOOL isSource))block;

// Returns YES if the local connected device is being presented on the TV.
-(void)requestIfLocalIsSource:(void (^)(BOOL isSource))block;

// Updates the physical address of the adapter.
-(void)updatePhysicalAddress:(uint16_t)address completion:(void (^)(BOOL success))block;

@end
