//
//  HSWStudent.h
//  labutilv8
//
//  Created by Brent Gray on 8/3/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWLabDocument.h"

@interface HSWStudent : NSManagedObject {
	BOOL lock;
}

// calculated fields
-(int)totalPoints;
- (NSString*)fullName;
// returns a string-formatted grading summary (score only)
- (NSString *)gradingSummary;
- (NSColor *)statusFontColor;

@end
