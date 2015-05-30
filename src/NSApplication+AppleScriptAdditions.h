//
//  NSApplication+AppleScriptAdditions.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 30/05/15.
//  Copyright (c) 2015 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DKCECDeviceController;

@interface NSApplication (AppleScriptAdditions)

@property (nonatomic, readonly) DKCECDeviceController *applescriptCecController;

@end
