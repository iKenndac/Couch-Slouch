//
//  DKCECDeviceController+SoftReset.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 05/10/2013.
//  For license information, see LICENSE.markdown
//

#import "DKCECDeviceController+SoftReset.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/IOMessage.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/serial/IOSerialKeys.h>

@implementation DKCECDeviceController (SoftReset)

-(BOOL)softResetCECAdapter {
	return [self findCECDeviceOnBusResettingIfFound:YES];
}

#define CEC_VID  0x2548
#define CEC_PID  0x1001
#define CEC_PID2 0x1002

-(BOOL)findCECDeviceOnBusResettingIfFound:(BOOL)shouldReset {

	mach_port_t masterPort;
    kern_return_t kernResult = KERN_SUCCESS;
    io_iterator_t intfIterator;

    kernResult = IOMasterPort(bootstrap_port, &masterPort);
    if (KERN_SUCCESS != kernResult) {
        NSLog(@"IOMasterPort returned 0x%08x\n", kernResult);
		return NO;
	}

	CFDictionaryRef ref = IOServiceMatching(kIOUSBDeviceClassName);
	if (!ref) {
		printf("%s(): IOServiceMatching returned a NULL dictionary.\n", __func__);
		return NO;
	}

	kernResult = IOServiceGetMatchingServices(masterPort, ref, &intfIterator);
	if (KERN_SUCCESS != kernResult) {
        NSLog(@"IOServiceGetMatchingServices returned 0x%08x\n", kernResult);
		return NO;
	}

	BOOL retValue = [self findCECDeviceOnUSBPlane:intfIterator shouldReset:shouldReset];

	IOObjectRelease(intfIterator);

	return retValue;
}

-(BOOL)findCECDeviceOnUSBPlane:(io_iterator_t)iterator shouldReset:(BOOL)shouldReset {

	io_service_t serviceObject;
	IOCFPlugInInterface **plugInInterface = NULL;
	IOUSBDeviceInterface187 **dev = NULL;
	SInt32 score;
	kern_return_t kr;
	HRESULT result;
	CFMutableDictionaryRef entryProperties = NULL;

	while ((serviceObject = IOIteratorNext(iterator))) {
		IORegistryEntryCreateCFProperties(serviceObject, &entryProperties, NULL, 0);

		kr = IOCreatePlugInInterfaceForService(serviceObject,
											   kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
											   &plugInInterface, &score);

		if ((kr != kIOReturnSuccess) || !plugInInterface) {
			printf("%s(): Unable to create a plug-in (%08x)\n", __func__, kr);
			continue;
		}

		// create the device interface
		result = (*plugInInterface)->QueryInterface(plugInInterface,
													CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
													(LPVOID *)&dev);

		// don’t need the intermediate plug-in after device interface is created
		(*plugInInterface)->Release(plugInInterface);

		if (result || !dev) {
			printf("%s(): Couldn’t create a device interface (%08x)\n", __func__, (int) result);
			continue;
		}

		UInt16 vendorID, productID;
		(*dev)->GetDeviceVendor(dev, &vendorID);
		(*dev)->GetDeviceProduct(dev, &productID);

		if (vendorID == CEC_VID && (productID == CEC_PID || productID == CEC_PID2)) {

			if (!shouldReset) return YES;

			kr = (*dev)->USBDeviceOpen(dev);
			if (kr != kIOReturnSuccess)
				return NO;

			kr = (*dev)->ResetDevice(dev);
			if (kr != kIOReturnSuccess)
				return NO;

			kr = (*dev)->USBDeviceReEnumerate(dev, 0);
			if (kr != kIOReturnSuccess)
				return NO;

			kr = (*dev)->USBDeviceClose(dev);
			if (kr != kIOReturnSuccess) {
				NSLog(@"Closing failed");
				return YES;
			}

			return YES;
		}
		
	}
	
	return NO;
	
}


@end
