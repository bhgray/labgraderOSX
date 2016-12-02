//
//  HSWScoringTable.h
//  labutilv8
//
//  Created by Brent Gray on 8/5/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWStudent.h";

@interface HSWScoringTable : NSTableView {

	IBOutlet NSArrayController* rubricScoringController;
	IBOutlet NSArrayController* studentController;
}

@end
