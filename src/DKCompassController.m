//
//  DKCompassController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 10/10/2013.
//  Copyright (c) 2013 Daniel Kennett. All rights reserved.
//

#import "DKCompassController.h"
#import "Constants.h"
#import "DKCompassFace.h"

@implementation DKCompassController

-(id)init {

	self = [super init];
	if (self) {

		NSMutableArray *newFaces = [NSMutableArray new];

		NSArray *encodedFaces = [[NSUserDefaults standardUserDefaults] objectForKey:kCompassFacesUserDefaultsKey];

		for (NSDictionary *encodedFace in encodedFaces) {

			if (![encodedFace isKindOfClass:[NSDictionary class]])
				continue;

			DKCompassFace *face = [[DKCompassFace alloc] initWithPropertyListRepresentation:encodedFace];

			if (face) [newFaces addObject:face];
		}

		self.faces = [NSArray arrayWithArray:newFaces];
	}

	return self;
}

@end
