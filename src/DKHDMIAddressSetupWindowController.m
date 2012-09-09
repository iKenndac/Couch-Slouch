//
//  DKHDMIAddressSetupWindowController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 06/09/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKHDMIAddressSetupWindowController.h"
#import <QuartzCore/QuartzCore.h>

@interface DKHDMIAddressSetupWindowController ()

@end

typedef enum {
	kConnectionTypeIndexDirect = 0,
	kConnectionTypeIndexAVReceiver = 1
} ConnectionTypeIndex;

@implementation DKHDMIAddressSetupWindowController

-(id)init {
	return [self initWithWindowNibName:NSStringFromClass([self class])];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

	[self switchToView:self.wizardViewStep0 animated:NO forwards:YES];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

+(NSSet *)keyPathsForValuesAffectingBackEnabled {
	return [NSSet setWithObject:@"currentView"];
}

-(BOOL)backEnabled {
	return self.currentView != self.wizardViewStep0;
}

+(NSSet *)keyPathsForValuesAffectingNextEnabled {
	return [NSSet setWithObject:@"currentView"];
}

-(BOOL)nextEnabled {
	return YES;
}

+(NSSet *)keyPathsForValuesAffectingNextButtonTitle {
	return [NSSet setWithObject:@"currentView"];
}

-(NSString *)nextButtonTitle {
	if (self.currentView == self.wizardViewStep3)
		return NSLocalizedString(@"done title", @"");
	else
		return NSLocalizedString(@"next title", @"");
}

+(NSSet *)keyPathsForValuesAffectingConnectionTypeImage {
	return [NSSet setWithObject:@"connectionTypeIndex"];
}

-(NSImage *)connectionTypeImage {
	if (self.connectionTypeIndex == kConnectionTypeIndexDirect)
		return [NSImage imageNamed:@"tv-computer-large"];
	else
		return [NSImage imageNamed:@"tv-av-computer-large"];
}

#pragma mark -

-(void)doCompletion {

	NSUInteger secondAddressLevel = 0;
	if (self.connectionTypeIndex == kConnectionTypeIndexAVReceiver)
		secondAddressLevel = self.avReceiverHDMIPortIndex + 1;

	NSString *numberString = [NSString stringWithFormat:@"%@%@00", @(self.tvHDMIPortIndex + 1), @(secondAddressLevel)];
	[self.delegate hdmiAddressSetup:self shouldCloseWithNewAddress:@([numberString intValue])];
}

-(void)reset {
	self.avReceiverHDMIPortIndex = 0;
	self.tvHDMIPortIndex = 0;
	self.connectionTypeIndex = 0;
	[self switchToView:self.wizardViewStep0 animated:NO forwards:NO];
}

-(void)switchToView:(NSView *)newView animated:(BOOL)animated forwards:(BOOL)forwards {

	if (self.currentView == newView) return;

	newView.frame = self.wizardViewContainer.bounds;

	if (animated) {
		CATransition *transition = [CATransition animation];
		transition.type = kCATransitionPush;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		transition.subtype = forwards ? kCATransitionFromRight : kCATransitionFromLeft;
		self.wizardViewContainer.animations = @{ @"subviews" : transition };
	} else {
		self.wizardViewContainer.animations = nil;
	}

	if (self.currentView == nil)
		[self.wizardViewContainer.animator addSubview:newView];
	else
		[self.wizardViewContainer.animator replaceSubview:self.currentView with:newView];

	self.currentView = newView;
}

- (IBAction)pushCancel:(id)sender {
	[self.delegate hdmiAddressSetup:self shouldCloseWithNewAddress:nil];
}

- (IBAction)pushPrevious:(id)sender {

	if (self.currentView == self.wizardViewStep3) {
		if (self.connectionTypeIndex == kConnectionTypeIndexDirect)
			[self switchToView:self.wizardViewStep2Direct animated:YES forwards:NO];
		else
			[self switchToView:self.wizardViewStep2bAV animated:YES forwards:NO];

	} else if (self.currentView == self.wizardViewStep2bAV) {
		[self switchToView:self.wizardViewStep2aAV animated:YES forwards:NO];

	} else if (self.currentView == self.wizardViewStep2aAV || self.currentView == self.wizardViewStep2Direct) {
		[self switchToView:self.wizardViewStep1 animated:YES forwards:NO];

	} else if (self.currentView == self.wizardViewStep1) {
		[self switchToView:self.wizardViewStep0 animated:YES forwards:NO];
	}

}

- (IBAction)pushNext:(id)sender {

	if (self.currentView == self.wizardViewStep0) {
		[self switchToView:self.wizardViewStep1 animated:YES forwards:YES];

	} else if (self.currentView == self.wizardViewStep1) {
		if (self.connectionTypeIndex == kConnectionTypeIndexDirect)
			[self switchToView:self.wizardViewStep2Direct animated:YES forwards:YES];
		else
			[self switchToView:self.wizardViewStep2aAV animated:YES forwards:YES];

	} else if (self.currentView == self.wizardViewStep2aAV) {
		[self switchToView:self.wizardViewStep2bAV animated:YES forwards:YES];
		
	} else if (self.currentView == self.wizardViewStep2bAV || self.currentView == self.wizardViewStep2Direct) {
		[self switchToView:self.wizardViewStep3 animated:YES forwards:YES];

	} else {
		[self doCompletion];
	}
}

@end
