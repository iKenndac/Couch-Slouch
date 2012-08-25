//
//  DKBackgroundStyleForwarderView.m
//  MacCEC
//
//  Created by Daniel Kennett on 25/08/2012.
//  Copyright (c) 2012 Daniel Kennett. All rights reserved.
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
