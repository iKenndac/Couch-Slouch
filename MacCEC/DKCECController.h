//
//  DKCECController.h
//  MacCEC
//
//  Created by Daniel Kennett on 16/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cectypes.h"

@class DKCECController;

@protocol DKCECControllerDelegate <NSObject>
@optional

-(void)cecController:(DKCECController *)controller didLogMessage:(NSString *)message ofSeverity:(cec_log_level)logLevel;
-(void)cecController:(DKCECController *)controller didReceiveKeyPress:(cec_keypress)keyPress;
-(void)cecController:(DKCECController *)controller didReceiveCommand:(cec_command)command;
-(void)cecController:(DKCECController *)controller didReceiveAlert:(libcec_alert)alert forParamter:(libcec_parameter)parameter;
-(void)cecController:(DKCECController *)controller activationDidChangeForLogicalDevice:(cec_logical_address)device toState:(BOOL)activated;

@end

@interface DKCECController : NSObject

-(id)initWithDeviceName:(NSString *)name;

@property (nonatomic, readonly) cec_menu_state menuState;
@property (nonatomic, readonly) libcec_configuration configuration;
@property (nonatomic, readwrite, weak) id <DKCECControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL hasConnection;

// ----

// Transmit a raw command the the local connected device.
-(BOOL)transmitCommand:(cec_command)command;

// Send a power on command to the given device.
-(BOOL)sendPowerOnToDevice:(cec_logical_address)address;

// Send a standby command to the given device.
-(BOOL)sendPowerOffToDevice:(cec_logical_address)address;

// Get the power status of the given device
-(cec_power_status)powerStatusOfDevice:(cec_logical_address)device;

// Get the devices available on the HDMI bus, not including the local connected device.
-(cec_logical_addresses)activeDevicesOnHDMIBus;

// Get the local connected device address(es)
-(cec_logical_addresses)localDevices;

// Returns YES if the given device type is present on the bus.
-(BOOL)hasDeviceOfType:(cec_device_type)wantedDevice;

// Returns YES when the given device is present on the bus.
-(BOOL)hasDevice:(cec_logical_address)device;

// Returns the device that is the current source (i.e., being presented on the TV)
-(cec_logical_address)sourceDevice;

// Returns YES if the given device is being presented on the TV
-(BOOL)deviceIsSource:(cec_logical_address)device;

// Returns YES if the local connected device is being presented on the TV.
-(BOOL)isSource;

@end
