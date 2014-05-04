//
//  DKDeleteKeyTableView.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 04/05/14.
//  For license information, see LICENSE.markdown
//

#import "DKDeleteKeyTableView.h"

@implementation DKDeleteKeyTableView

-(void)keyDown:(NSEvent *)event {

	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	if (key == NSDeleteCharacter) {
		if ([self.delegate respondsToSelector:@selector(deleteBackward:)]) {
			[(NSResponder *)self.delegate deleteBackward:self];
			return;
		}
	}

	// still here?
	[super keyDown:event];
}

@end
