//
//  DKCECBehaviourController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 2013-09-25.
//  For license information, see LICENSE.markdown
//

#import <Foundation/Foundation.h>

@interface DKCECBehaviourController : NSObject

+(DKCECBehaviourController *)sharedInstance;

-(void)handleBecameActiveSource;
-(void)handleLostActiveSource;

-(void)handleTVSwitchedOn;
-(void)handleTVSwitchedOff;

@end
