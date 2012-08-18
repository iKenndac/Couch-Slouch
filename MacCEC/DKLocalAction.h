//
//  DKLocalAction.h
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cectypes.h"

@protocol DKLocalAction <NSObject>

-(id)initWithPropertyListRepresentation:(id)plist;
-(id)propertyListRepresentation;

-(void)performActionWithKeyPress:(cec_keypress)keyPress;
-(BOOL)matchesKeyPress:(cec_keypress)keyPress;

@end
