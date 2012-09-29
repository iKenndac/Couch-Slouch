//
//  DKFakeRemoteWindowController.m
//  Couch Slouch
//
//  Created by Daniel Kennett on 28/09/2012.
//  For license information, see LICENSE.markdown
//

#import "DKFakeRemoteWindowController.h"

@implementation DKFakeRemoteWindowController


-(void)awakeFromNib {
	NSPanel *panel = (NSPanel *)self.window;
	panel.becomesKeyOnlyIfNeeded = YES;
}

-(void)simulateKeypressWithCode:(cec_user_control_code)code {
	cec_keypress press;
	memset(&press, 0, sizeof(cec_keypress));
	press.keycode = code;

	[self.delegate handleSimulatedKeyPress:press];
}

-(IBAction)pushUp:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_UP];
}

-(IBAction)pushDown:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_DOWN];
}

-(IBAction)pushLeft:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_LEFT];
}

-(IBAction)pushRight:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_RIGHT];
}

-(IBAction)pushExit:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_EXIT];
}

-(IBAction)pushSelect:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_SELECT];
}


-(IBAction)push1:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER1];
}

-(IBAction)push2:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER2];
}

-(IBAction)push3:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER3];
}

-(IBAction)push4:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER4];
}

-(IBAction)push5:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER5];
}

-(IBAction)push6:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER6];
}

-(IBAction)push7:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER7];
}

-(IBAction)push8:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER8];
}

-(IBAction)push9:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_NUMBER9];
}

-(IBAction)pushRed:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_F2_RED];
}

-(IBAction)pushGreen:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_F3_GREEN];
}

-(IBAction)pushYellow:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_F4_YELLOW];
}

-(IBAction)pushBlue:(id)sender {
	[self simulateKeypressWithCode:CEC_USER_CONTROL_CODE_F1_BLUE];
}

@end
