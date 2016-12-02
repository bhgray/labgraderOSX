//
//  HSWPrefsController.m
//  labutilv8
//
//  Created by Brent Gray on 8/5/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import "HSWPrefsController.h"

@implementation HSWPrefsController

- (id) init {
	self = [super initWithWindowNibName:@"HSWPreferences"];
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) windowDidLoad {
	[atStartupMatrix selectCellWithTag:[self startUpBehavior]];
	if (!DEBUG) {
		[debugStatusBox setHidden:YES]; 
	} else {
		[debugStatusMatrix selectCellWithTag:[self debugStatus]];		
	}
}

- (HSWStartupBehavior) startUpBehavior {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:HSWStartupBehaviorKey];
}

- (HSWDebugStatus) debugStatus {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:HSWDebugStatusKey];
}

- (IBAction) okButton:(id)sender {
	[self applyButton:sender];
	[self close];
}

- (IBAction) cancelButton:(id)sender {
	[self close];
}

- (IBAction) applyButton:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:[atStartupMatrix selectedRow] 
											   forKey:HSWStartupBehaviorKey];
	[[NSUserDefaults standardUserDefaults] setInteger:[debugStatusMatrix selectedRow] 
											   forKey:HSWDebugStatusKey];
}

@end
