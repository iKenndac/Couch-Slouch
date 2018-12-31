//
//  DKBackgroundColorView.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 2018-12-31.
//  Copyright © 2018 Daniel Kennett. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface DKBackgroundColorView : NSView

@property (nonatomic, readwrite, copy, nullable) IBInspectable NSColor *backgroundColor;

@end
