//
//  DKBackgroundStyleForwarderView.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 25/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKBackgroundStyleForwarderView.h"

@implementation DKBackgroundStyleForwarderView

-(void)setBackgroundStyle:(NSBackgroundStyle)style {
	for (NSView *aView in self.subviews) {
		if ([aView respondsToSelector:_cmd])
			[(id)aView setBackgroundStyle:style];
		else if ([aView isKindOfClass:[NSControl class]])
			[[(NSControl *)aView cell] setBackgroundStyle:style];
	}
}

@end
