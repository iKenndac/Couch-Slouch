//
//  DKBehavioursViewController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKBehavioursViewController.h"
#import "DKCECBehaviourController.h"

@interface DKBehavioursViewController ()
@end

@implementation DKBehavioursViewController

-(id)init {
	return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (IBAction)chooseScript:(id)sender {

	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.allowedFileTypes = @[@"scpt"];

	[openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelCancelButton)
			return;

		NSURL *url = openPanel.URL;
		[[DKCECBehaviourController sharedInstance] setScriptURL:url];
	}];

}

@end
