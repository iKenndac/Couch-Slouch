//
//  DKScriptRunnerXPCController.h
//  Couch Slouch
//
//  Created by Daniel Kennett on 29/09/2013.
//  For license information, see LICENSE.markdown
//


#import <Foundation/Foundation.h>

@protocol DKCouchSlouchRunScript

-(void)runFunction:(NSString *)function
	 inScriptAtURL:(NSURL *)scriptURL
		  callback:(void (^)(NSURL *scriptURL, NSDictionary *errorDictionary))block;

@end

@interface DKScriptRunnerXPCController : NSObject <NSXPCListenerDelegate, DKCouchSlouchRunScript>

@end
