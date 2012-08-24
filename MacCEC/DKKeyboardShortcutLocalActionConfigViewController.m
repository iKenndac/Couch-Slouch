//
//  DKKeyboardShortcutLocalActionConfigViewController.m
//  MacCEC
//
//  Created by Daniel Kennett on 22/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
//

#import "DKKeyboardShortcutLocalActionConfigViewController.h"
#import "DKKeyboardShortcutLocalAction.h"

@interface DKKeyboardShortcutLocalActionConfigViewController ()

@end

@implementation DKKeyboardShortcutLocalActionConfigViewController

@synthesize recorder;

-(id)init {
	return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

-(void)awakeFromNib {
	[self.recorder setAllowsKeyOnly:YES escapeKeysRecord:YES];
	DKKeyboardShortcutLocalAction *action = self.representedObject;
	if (action)
		[self.recorder setKeyCombo:SRMakeKeyCombo(action.localTranslatedKeyCode, action.flags)];
}

-(void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
	DKKeyboardShortcutLocalAction *action = self.representedObject;
	if (action)
		[self.recorder setKeyCombo:SRMakeKeyCombo(action.localTranslatedKeyCode, action.flags)];
}

-(BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason {
	return NO;
}

-(void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo {
	DKKeyboardShortcutLocalAction *action = self.representedObject;
	[action setLocalKeyFromKeyCode:newKeyCombo.code];
	action.flags = newKeyCombo.flags;
	[[DKCECKeyMappingController sharedController] saveMappings];
}

@end
