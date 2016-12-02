//
//  HSWLab.m
//  labutilv8
//
//  Created by Brent Gray on 8/3/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import "HSWLab.h"

@implementation HSWLab

- (void) awakeFromInsert {
    [super awakeFromInsert];
}


+ (HSWLab *)generateTestingData:(NSManagedObjectContext*)context
{
	
	HSWLab* aLab = [NSEntityDescription insertNewObjectForEntityForName:@"Lab"
												 inManagedObjectContext:context];
	[aLab setValue:@"LabJ1:  BankAccount" forKey:@"name"];
	[aLab setValue:@"LABJ1" forKey:@"key"];

	HSWCourse *aCourse = [NSEntityDescription insertNewObjectForEntityForName:@"Course"
													   inManagedObjectContext:context];
	[aCourse setValue:@"Advanced Placement Computer Science" forKey:@"name"];
	[aCourse setValue:@"APCS" forKey:@"key"];
	[aCourse setValue:@40 forKey:@"totalPoints"];
	

	[aLab setValue:aCourse forKey:@"assignedToCourse"];
	[aCourse setValue:aLab forKey:@"completesLab"];
	
	NSMutableSet* students = [NSMutableSet new];
	HSWStudent* aStudent = [NSEntityDescription insertNewObjectForEntityForName:@"Student"
														 inManagedObjectContext:context];
	[aStudent setValue:@"Gray" forKey:@"lastName"];
	[aStudent setValue:@"Brent" forKey:@"firstName"];
	[aStudent setValue:@"bhgray@gmail.com" forKey:@"email"];
	[aStudent setValue:aCourse forKey:@"enrolledInCourse"];
	
	[students addObject:aStudent];
	
	aStudent = [NSEntityDescription insertNewObjectForEntityForName:@"Student"
														 inManagedObjectContext:context];
	[aStudent setValue:@"Gray" forKey:@"lastName"];
	[aStudent setValue:@"Tommy" forKey:@"firstName"];
	[aStudent setValue:@"tommygray@gmail.com" forKey:@"email"];
	[aStudent setValue:aCourse forKey:@"enrolledInCourse"];
	
	[students addObject:aStudent];
	
	aStudent = [NSEntityDescription insertNewObjectForEntityForName:@"Student"
											 inManagedObjectContext:context];
	[aStudent setValue:@"Gray" forKey:@"lastName"];
	[aStudent setValue:@"Luke" forKey:@"firstName"];
	[aStudent setValue:@"lukegray@gmail.com" forKey:@"email"];
	[aStudent setValue:aCourse forKey:@"enrolledInCourse"];
	
	[students addObject:aStudent];
	[aCourse setValue:students forKey:@"hasRosteredStudents"];
	
	NSMutableSet* rubricElements = [NSMutableSet new];
	HSWRubricElement* el = [NSEntityDescription insertNewObjectForEntityForName:@"RubricElement"
														 inManagedObjectContext:context];
	[el setValue:@"GEN" forKey:@"type"];
	[el setValue:@-1	forKey:@"points"];
	[el setValue:@"-1 Gen Comment" forKey:@"text"];
	[el setValue:aLab forKey:@"usedInLab"];
	[rubricElements addObject:el];

	
	el = [NSEntityDescription insertNewObjectForEntityForName:@"RubricElement"
									   inManagedObjectContext:context];
	[el setValue:@"GEN" forKey:@"type"];
	[el setValue:@-2	forKey:@"points"];
	[el setValue:@"-2 Gen Comment" forKey:@"text"];
	[el setValue:aLab forKey:@"usedInLab"];
	[rubricElements addObject:el];
	
	el = [NSEntityDescription insertNewObjectForEntityForName:@"RubricElement"
									   inManagedObjectContext:context];
	[el setValue:@"GEN" forKey:@"type"];
	[el setValue:@-3	forKey:@"points"];
	[el setValue:@"-3 Gen Comment" forKey:@"text"];
	[el setValue:aLab forKey:@"usedInLab"];
	[rubricElements addObject:el];

	el = [NSEntityDescription insertNewObjectForEntityForName:@"RubricElement"
									   inManagedObjectContext:context];
	[el setValue:@"GEN" forKey:@"type"];
	[el setValue:@-4	forKey:@"points"];
	[el setValue:@"-4 Gen Comment" forKey:@"text"];
	[el setValue:aLab forKey:@"usedInLab"];
	[rubricElements addObject:el];
	
	[aLab setValue:rubricElements forKey:@"hasRubricElements"];
	
	return aLab;
}


@end
