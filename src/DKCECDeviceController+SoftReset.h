//
//  DKCECDeviceController+SoftReset.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 05/10/2013.
//  For license information, see LICENSE.markdown
//

#import "DKCECDeviceController.h"

@interface DKCECDeviceController (SoftReset)

/**
 This method finds any CEC adapters on the USB bus and soft-resets them. 
 
 Either the CEC adapter or OS X or *something* has a bug that causes the
 serial port service on the adapter to not be recognised if it's connected
 while the system boots. This can be fixed by finding the device on the
 USB bus directly and soft-resetting it.

 @return Returns `YES` if an adapter was found and successfully reset.
 */
-(BOOL)softResetCECAdapter;

@end
