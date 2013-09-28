//
//  DKBehavioursViewController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 18/08/2012.
//  For license information, see LICENSE.markdown
//

#import "DKBehavioursViewController.h"
#import "DKCECBehaviourController.h"
#import "DKBehaviourScriptController.h"
#import "Constants.h"

@interface DKBehavioursViewController ()
@property (nonatomic, readwrite) DKBehaviourScriptController *scriptController;
@end

@implementation DKBehavioursViewController

-(id)init {
	self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (self) {
		self.scriptController = [DKBehaviourScriptController new];
	}
	return self;
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

- (IBAction)openScriptsFolder:(id)sender {
	[self.scriptController openUserScriptsFolder];
}

- (IBAction)openWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kCouchSlouchWebsiteURL]];
}

@end
