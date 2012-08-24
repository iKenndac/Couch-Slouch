//
//  DKLocalAction.h
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cectypes.h"
#import "DKCECKeyMappingController.h"

@class DKCECKeyMapping;

@protocol DKLocalAction <NSObject>

-(id)initWithDeviceKeyCode:(cec_user_control_code)deviceCode;
-(id)initWithPropertyListRepresentation:(id)plist;
-(id)propertyListRepresentation;

@property (nonatomic, readonly) cec_user_control_code deviceKeyCode;
@property (nonatomic, readwrite, weak) DKCECKeyMapping *parentMapping;

-(void)performActionWithKeyPress:(cec_keypress)keyPress;
-(BOOL)matchesKeyPress:(cec_keypress)keyPress;

@end

@interface DKLocalAction : NSObject <DKLocalAction>

+(void)registerViewControllerClass:(Class)controllerClass description:(NSString *)desc forLocalActionOfClass:(Class)localActionClass;
+(NSArray *)registeredConfigViewControllers;

-(NSString *)deviceKeyCodeDisplayName;

@property (nonatomic, readonly) cec_user_control_code deviceKeyCode;

@end
