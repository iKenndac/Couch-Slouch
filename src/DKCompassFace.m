//
//  DKCompassFace.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 10/10/2013.
//  Copyright (c) 2013 Daniel Kennett. All rights reserved.
//

#import "DKCompassFace.h"
#import "Constants.h"

@implementation DKCompassFace

-(id)initWithPropertyListRepresentation:(id)plist {
	self = [super init];
	if (self) {

		self.upAction = [DKLocalAction localActionWithPropertyList:plist[kCompassDirectionUpKey]];
		self.downAction = [DKLocalAction localActionWithPropertyList:plist[kCompassDirectionDownKey]];
		self.leftAction = [DKLocalAction localActionWithPropertyList:plist[kCompassDirectionLeftKey]];
		self.rightAction = [DKLocalAction localActionWithPropertyList:plist[kCompassDirectionRightKey]];

	}
	return self;
}

-(NSDictionary *)propertyListRepresentation {

	NSMutableDictionary *plist = [NSMutableDictionary new];

	id up = [self.upAction propertyListRepresentation];
	if (up) plist[kCompassDirectionUpKey] = up;

	id down = [self.downAction propertyListRepresentation];
	if (down) plist[kCompassDirectionDownKey] = down;

	id left = [self.leftAction propertyListRepresentation];
	if (left) plist[kCompassDirectionLeftKey] = left;

	id right = [self.rightAction propertyListRepresentation];
	if (right) plist[kCompassDirectionRightKey] = right;

	return [NSDictionary dictionaryWithDictionary:plist];
}

@end
