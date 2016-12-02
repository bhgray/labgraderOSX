//
//  HSWRubricElement.m
//  labutilv8
//
//  Created by Brent Gray on 9/28/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import "HSWRubricElement.h"


@implementation HSWRubricElement


+ (NSArray *)copyKeys {
    static NSArray *copyKeys = nil;
    if (copyKeys == nil) {
        copyKeys = [[NSArray alloc] initWithObjects:
            @"type", @"text", @"points", @"submissionElement", nil];
    }
    return copyKeys;
}

- (NSString *)summary
{
	NSString *filename = ([self valueForKey:@"submissionElement"] != nil ? [NSString stringWithFormat:@"(%@)", [self valueForKey:@"submissionElement"]] : @"");
	NSString *type = ([self valueForKey:@"type"] != nil ? [self valueForKey:@"type"] : @"");
	NSString *points = ([self valueForKey:@"points"] != nil ? [self valueForKey:@"points"] : @"");
	NSString *text = ([self valueForKey:@"text"] != nil ? [self valueForKey:@"text"] : @"");
	
	return [NSString stringWithFormat:@"[%@] - [%@] %@ %@", type, points, text, filename];
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[[self class] copyKeys]];
}

@end
