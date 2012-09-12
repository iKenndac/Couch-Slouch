//
//  DKHDMIAddressSetupWindowController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 06/09/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>

@class DKHDMIAddressSetupWindowController;

@protocol DKHDMIAddressSetupWindowControllerDelegate <NSObject>

-(void)hdmiAddressSetup:(DKHDMIAddressSetupWindowController *)controller shouldCloseWithNewAddress:(NSNumber *)address;

@end

@interface DKHDMIAddressSetupWindowController : NSWindowController

@property (nonatomic, readwrite, weak) id <DKHDMIAddressSetupWindowControllerDelegate> delegate;

@property (nonatomic, readwrite) NSInteger tvHDMIPortIndex;
@property (nonatomic, readwrite) NSInteger avReceiverHDMIPortIndex;
@property (nonatomic, readwrite) NSInteger connectionTypeIndex;
@property (strong, readwrite, nonatomic) NSView *currentView;
@property (readonly, nonatomic) NSString *nextButtonTitle;

@property (strong) IBOutlet NSView *wizardViewStep0;
@property (strong) IBOutlet NSView *wizardViewStep1;
@property (strong) IBOutlet NSView *wizardViewStep2Direct;
@property (strong) IBOutlet NSView *wizardViewStep2aAV;
@property (strong) IBOutlet NSView *wizardViewStep2bAV;
@property (strong) IBOutlet NSView *wizardViewStep3;
@property (weak) IBOutlet NSView *wizardViewContainer;

@property (nonatomic, readonly) BOOL backEnabled;
@property (nonatomic, readonly) BOOL nextEnabled;
@property (nonatomic, readwrite) BOOL cancelEnabled;

- (IBAction)pushCancel:(id)sender;
- (IBAction)pushPrevious:(id)sender;
- (IBAction)pushNext:(id)sender;

-(void)reset;

@property (nonatomic, readonly) NSImage *connectionTypeImage;

@end
