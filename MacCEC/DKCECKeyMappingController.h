//
//  DKCECKeyMapping.h
//  MacCEC
//
//  Created by Daniel Kennett on 18/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cectypes.h"
#import "DKLocalAction.h" 

@class DKCECKeyMapping;
@protocol DKLocalAction;

@interface DKCECKeyMappingController : NSObject

+(DKCECKeyMappingController *)sharedController;

@property (nonatomic, readonly, strong) DKCECKeyMapping *baseMapping;
@property (nonatomic, readonly) NSArray *applicationMappings;

-(DKCECKeyMapping *)keyMappingForApplicationWithIdentifier:(NSString *)appIdentifier;
-(DKCECKeyMapping *)duplicateMapping:(DKCECKeyMapping *)mapping withNewApplicationIdentifier:(NSString *)appIdentifier;

-(void)saveMappings;

@end

@interface DKCECKeyMapping : NSObject <NSCopying>

-(id <DKLocalAction>)actionForKeyPress:(cec_keypress)keypress;

-(id)initWithPropertyListRepresentation:(NSDictionary *)plist;
-(NSDictionary *)propertyListRepresentation;

-(void)addAction:(id <DKLocalAction>)action;
-(void)removeAction:(id <DKLocalAction>)action;
-(void)addActions:(NSArray *)actions;
-(void)removeActions:(NSArray *)actions;

@property (nonatomic, readwrite, copy) NSString *applicationIdentifier;
@property (nonatomic, readonly, copy) NSString *lastKnownName;
@property (nonatomic, readonly, copy) NSArray *actions;

@property (nonatomic, readonly, copy) NSString *displayName;
@property (nonatomic, readonly, copy) NSImage *displayImage;

@end
