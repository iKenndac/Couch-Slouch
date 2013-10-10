//
//  DKCompassFace.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 10/10/2013.
//  Copyright (c) 2013 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKLocalAction.h"

@interface DKCompassFace : NSObject

-(id)initWithPropertyListRepresentation:(id)plist;
-(NSDictionary *)propertyListRepresentation;

@property (nonatomic, readwrite) DKLocalAction *upAction;
@property (nonatomic, readwrite) DKLocalAction *downAction;
@property (nonatomic, readwrite) DKLocalAction *leftAction;
@property (nonatomic, readwrite) DKLocalAction *rightAction;

@end
