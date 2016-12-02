//
//  HSWPrefsController.h
//  labutilv8
//
//  Created by Brent Gray on 8/5/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWLabDocument.h"

@interface HSWPrefsController : NSWindowController {
	IBOutlet NSMatrix *atStartupMatrix;
	IBOutlet NSMatrix *debugStatusMatrix;
	IBOutlet NSBox *debugStatusBox;
	IBOutlet NSButton *okButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *applyButton;
	IBOutlet NSButton *defaultsButton;
	IBOutlet NSForm* emailPrefsForm;
	IBOutlet NSButton* useSSLButton;
	IBOutlet NSPopUpButton* loginMechanismButton;
}

- (IBAction) okButton:(id)sender;
- (IBAction) cancelButton:(id)sender;
- (IBAction) applyButton:(id)sender;
//- (HSWStartupBehavior) startUpBehavior;
//- (HSWDebugStatus) debugStatus;
@end
