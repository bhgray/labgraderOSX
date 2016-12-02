//
//  HSWCourse.m
//  labutilv8
//
//  Created by Brent Gray on 8/3/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import "HSWCourse.h"


@implementation HSWCourse

- (void) awakeFromInsert {
    [super awakeFromInsert];
	
	// set the due date initially to today
    [self setValue:[NSDate date] forKey:@"dueDate"];
}

@end
