//
//  HSWLab.h
//  labutilv8
//
//  Created by Brent Gray on 8/3/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWCourse.h"
#import "HSWStudent.h"
#import "HSWRubricElement.h"


@interface HSWLab : NSManagedObject {

}

+ (HSWLab *)generateTestingData:(NSManagedObjectContext*)context;

@end
