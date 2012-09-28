//
//  DKMouseGridView.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2012.
//  For license information, see LICENSE.markdown
//

#import <Cocoa/Cocoa.h>

@interface DKMouseGridView : NSView

@property (nonatomic, readwrite) BOOL drawBorder;

-(NSRect)rectForSegment:(NSUInteger)segmentIndex;

@end
