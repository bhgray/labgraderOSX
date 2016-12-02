//
//  HSWStudent.m
//  labutilv8
//
//  Created by Brent Gray on 8/3/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import "HSWStudent.h"


@implementation HSWStudent

+ (void)initialize {
    if (self == [HSWStudent class])
    {
        [self setKeys:@[@"lastName", @"firstName"] triggerChangeNotificationsForDependentKey:@"fullName"];
		[self setKeys:@[@"hasGradeElements"] triggerChangeNotificationsForDependentKey:@"totalPoints"];
		[self setKeys:@[@"totalPoints"] triggerChangeNotificationsForDependentKey:@"gradingSummary"];
    }
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	lock = false;
}

//- (NSDictionary *)valuesForKeys
//{
//	NSMutableDictionary *returnVals = [NSMutableDictionary new];
//
//	[returnVals setValue:[self valueForKey:@"fullName"] forKey:HSWStudentName];
//	[returnVals setValue:[self valueForKey:@"totalPoints"] forKey:HSWStudentScore];
//	[returnVals setValue:[self valueForKey:@"overridePoints"] forKey:HSWStudentOverrideScore];
//	[returnVals setValue:[self valueForKey:@"email"] forKey:HSWStudentEmail];
//	if ([self valueForKey:@"note"] != nil) {
//		[returnVals setValue:[self valueForKey:@"note"] forKey:HSWStudentComment];				
//	} else {
//		[self setValue:@"None" forKey:HSWStudentComment];
//	}
//	
//	[returnVals setValue:[[[labController content] valueForKey:@"assignedToCourse"] valueForKey:@"totalPoints"] forKey:HSWTotalPoints];
//	[returnVals setValue:[[labController content] valueForKey:@"name"] forKey:HSWLabName];
//	
//	// find all the selected objects in the rubricGradingController
//	NSArray *selectedRubricElements = [rubricGradingController selectedObjects];
//	NSEnumerator *enumerator = [selectedRubricElements objectEnumerator];
//	HSWRubricElement *value;
//	NSMutableArray *comments = [NSMutableArray new];
//	while ((value = [enumerator nextObject])) {
//		[comments addObject:[value summary]];
//	}
//	[returnVals setValue:comments forKey:HSWLabComments];
//	NSLog(@"%@", [returnVals description]);
//	return [returnVals autorelease];
//}

-(int)totalPoints
{
	NSSet *selectedRubricElements = [self valueForKey:@"hasGradeElements"];
	int total = 0;
	if (selectedRubricElements != nil) {
		id value;
		
		for (value in selectedRubricElements) {
			total += [[value valueForKey:@"points"] intValue];
		}
	}
	
	// get the lab total points....
	int possible = [[[self valueForKey:@"enrolledInCourse"] valueForKey:@"totalPoints"] intValue];
	
	return possible + total;
}

- (NSString *)fullName
{
	return [NSString stringWithFormat:@"%@ %@", 
			[self valueForKey:@"firstName"], 
			[self valueForKey:@"lastName"]];
}

/*
	ideally, the record should lock once you send the email. Any further change should
	trigger an alert sheet asking whether you want to unlock.
 */

- (BOOL) recordLocked {
	return lock;
}

- (NSString *)gradingSummary 
{
	int numberOfRubricItemsSelected = [[self valueForKey:@"hasGradeElements"] count];
	double possible = [[[self valueForKey:@"enrolledInCourse"] valueForKey:@"totalPoints"] intValue];
	return [NSString stringWithFormat:@"%d - %1.1f%@ (%d)", 
			[[self valueForKey:@"totalPoints"] intValue], 
			([[self valueForKey:@"totalPoints"] intValue] / possible) * 100,
			@"%",
			numberOfRubricItemsSelected];
}

+ (NSArray *)copyKeys {
    static NSArray *copyKeys = nil;
    if (copyKeys == nil) {
        copyKeys = [[NSArray alloc] initWithObjects:
            @"firstName", @"lastName", @"idNumber", @"email", nil];
    }
    return copyKeys;
}

- (NSString *)summary
{
	return [NSString stringWithFormat:@"%@, %@ (%@) (%@)", [self valueForKey:@"lastName"], [self valueForKey:@"firstName"], [self valueForKey:@"idNumber"], [self valueForKey:@"email"]];
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[[self class] copyKeys]];
}

- (NSColor *)statusFontColor{
	BOOL result = [[self valueForKey:@"emailSent"] boolValue];
	if (result) {
		return [NSColor greenColor];
	} else {
		return [NSColor redColor];
	}
}

@end
