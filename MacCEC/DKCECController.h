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

@property (nonatomic, readonly) cec_menu_state menuState;
@property (nonatomic, readonly) libcec_configuration configuration;
@property (nonatomic, readwrite, weak) id <DKCECControllerDelegate> delegate;

@end
