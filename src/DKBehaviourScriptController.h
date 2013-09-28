//
//  DKBehaviourScriptController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2013.
//  For license information, see LICENSE.markdown
//

#import <Foundation/Foundation.h>

@interface DKBehaviourScriptController : NSObject

@property (nonatomic, readonly) NSArray *scripts;

-(void)openUserScriptsFolder;

@end
