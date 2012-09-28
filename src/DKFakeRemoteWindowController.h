//
//  DKFakeRemoteWindowController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>
#import "cectypes.h"

@protocol DKFakeRemoteDelegate <NSObject>

-(void)handleSimulatedKeyPress:(cec_keypress)press;

@end

@interface DKFakeRemoteWindowController : NSWindowController

@property (nonatomic, weak, readwrite) id <DKFakeRemoteDelegate> delegate;

-(IBAction)pushUp:(id)sender;
-(IBAction)pushDown:(id)sender;
-(IBAction)pushLeft:(id)sender;
-(IBAction)pushRight:(id)sender;
-(IBAction)pushExit:(id)sender;
-(IBAction)pushSelect:(id)sender;

-(IBAction)push1:(id)sender;
-(IBAction)push2:(id)sender;
-(IBAction)push3:(id)sender;
-(IBAction)push4:(id)sender;
-(IBAction)push5:(id)sender;
-(IBAction)push6:(id)sender;
-(IBAction)push7:(id)sender;
-(IBAction)push8:(id)sender;
-(IBAction)push9:(id)sender;


@end
