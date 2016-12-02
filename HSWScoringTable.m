//
//  HSWScoringTable.m
//  labutilv10
//  Created by Brent Gray on 08-05-07.
//	Modified by Brent Gray on 11-04-07
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import "HSWScoringTable.h"


@implementation HSWScoringTable

- (void)mouseDown:(NSEvent *)theEvent 
{
	
	NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	int i = [self rowAtPoint:p];
	NSMutableIndexSet* newSelects = nil;
	HSWStudent* currentStudent = nil;
	NSSet* selectedRubricElements = nil;
	
	if ([[studentController selectedObjects] count] > 0) 
	{
		if (![self isRowSelected:i]) 
		{
			newSelects = [NSIndexSet indexSetWithIndex:i];
			[self selectRowIndexes: newSelects byExtendingSelection:YES];
			[rubricScoringController addSelectionIndexes: newSelects];
		} else 
		{
			newSelects = [[NSMutableIndexSet alloc ] initWithIndexSet:[self selectedRowIndexes]];
			[newSelects removeIndex:i];
			[rubricScoringController setSelectionIndexes:newSelects];
			[self selectRowIndexes:newSelects byExtendingSelection:NO];

		}
		selectedRubricElements = [NSSet setWithArray:[rubricScoringController selectedObjects]];
		currentStudent = [studentController selectedObjects][0];
		[currentStudent willChangeValueForKey:@"hasGradeElements"];
		[currentStudent setValue:selectedRubricElements forKey:@"hasGradeElements"];
		[currentStudent didChangeValueForKey:@"hasGradeElements"];
	} else
	{
		[rubricScoringController setSelectionIndexes:[NSIndexSet new]];		
	}
	

}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification  
{
	
	if ([[studentController selectedObjects] count] > 0) {
		HSWStudent *currentStudent = [studentController selectedObjects][0];
		NSSet *rubricElements = [currentStudent valueForKey:@"hasGradeElements"];
		[rubricScoringController setSelectedObjects:[rubricElements allObjects]];
	}
}


@end
