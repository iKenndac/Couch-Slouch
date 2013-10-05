//
//  DKCECBehaviourController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 2013-09-25.
//  For license information, see LICENSE.markdown
//

#import <Foundation/Foundation.h>
#import "DKCECDeviceController.h"

@interface DKCECBehaviourController : NSObject

+(DKCECBehaviourController *)sharedInstance;

@property (nonatomic, readwrite) DKCECDeviceController *device;

-(void)handleBecameActiveSource;
-(void)handleLostActiveSource;

-(void)handleTVSwitchedOn;
-(void)handleTVSwitchedOff;

-(void)handleMacStartup;
-(void)handleMacAwake;
-(void)handleMacSleep:(dispatch_block_t)block;
-(void)handleMacShutdown:(dispatch_block_t)block;

@end
