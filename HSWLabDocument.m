//
//  HSWLabDocument.m
//  LabUtilv10
//
//  Created by Brent Gray on 11/4/07.
//  Copyright Havalina Software Works 2007 . All rights reserved.
//

#import "HSWLabDocument.h"
#import "HSWRubricElement.h"
#import "HSWPrefsController.h"

@class HSWStudent;

// preferences keys
NSString*	HSWStartupBehaviorKey						=	@"startup";
NSString*	HSWDebugStatusKey							=	@"debug";
NSString*	HSWFragmentsPathKey							=	@"fragmentsPath";
NSString*	HSWLabUtilShortAppName						=	@"LabUtil";

// model keys
NSString*	HSWStudentName								= @"fullName";
NSString*	HSWLabName									= @"HSWLabName";
NSString*	HSWStudentOverrideScore						= @"overridePoints";
NSString*	HSWStudentEmail								= @"email";
NSString*	HSWTotalPoints								= @"totalPoints";
NSString*	HSWStudentScore								= @"totalPoints";
NSString*	HSWLabComments								= @"hasGradeElements";
NSString*	HSWStudentComment							= @"note";



@implementation HSWLabDocument

+ (void)initialize {
	static BOOL initialized = NO;
	if (!initialized) {
		
		// create default values for the user defaults
		NSMutableDictionary *userDefaultsValuesDict;
		userDefaultsValuesDict = [NSMutableDictionary dictionary];
		userDefaultsValuesDict[HSWStartupBehaviorKey] = @(HSWDoNothingAtStartup);
		if (DEBUG) {
			userDefaultsValuesDict[HSWDebugStatusKey] = @(HSWGenerateTestingData);			
		} else {
			userDefaultsValuesDict[HSWDebugStatusKey] = @(HSWNoTestingData);						
		}
		[[NSUserDefaults standardUserDefaults] registerDefaults: userDefaultsValuesDict];
		
		initialized = YES;		
	}
}

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
		importStudentsFlag = NO;
		importStudentsOverwriteFlag = NO;
    }
    return self;
}

- (NSString *)windowNibName 
{
    return @"HSWLabDocument";
}

//	bug from:  http://lists.apple.com/archives/cocoa-dev/2007/Nov/msg00158.html

-(IBAction)saveDocument:(id)sender
{
    if ([[self managedObjectContext] hasChanges])
    {
		[super saveDocument:sender];
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
	[self initializeToolbar];
}

- (BOOL)revertToContentsOfURL:(NSURL *)inAbsoluteURL ofType:(NSString *)inTypeName error:(NSError **)outError

{
	[labController setContent:nil];
    return [super revertToContentsOfURL:inAbsoluteURL ofType:inTypeName error:outError];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	
	NSLog(@"Terminating %@", sender);
	return NSTerminateNow;
	
}

- (id)initWithType:(NSString *)type error:(NSError **)error {
    self = [super initWithType:type error:error];
    if (self != nil) {
		NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        [[managedObjectContext undoManager] disableUndoRegistration];
		
		if ([[NSUserDefaults standardUserDefaults] integerForKey:HSWDebugStatusKey] == HSWGenerateTestingData)
		{
			lab = [HSWLab generateTestingData:managedObjectContext];
		} else 
		{
			lab = [NSEntityDescription insertNewObjectForEntityForName:@"Lab" inManagedObjectContext:managedObjectContext];
			HSWCourse *course = [NSEntityDescription insertNewObjectForEntityForName:@"Course"
															  inManagedObjectContext:managedObjectContext];
			[lab setValue:course forKey:@"assignedToCourse"];
			[course setValue:lab forKey:@"completesLab"];
			//		[self setRootDirectoryFromFilename:[lab valueForKey:@"studentRootDir"]];
		}
		[managedObjectContext processPendingChanges];
		[[managedObjectContext undoManager] enableUndoRegistration]; 			
	}
    return self;
}

- (void)setLab:(HSWLab *)aLab {
	
    if ([labController content] != aLab) {
		
        [labController setContent: aLab];
		
    }
}

- (HSWLab *)lab
{
	
	return [labController content];
}

- (NSString *)windowTitleForDocumentDisplayName: (NSString *)displayName
{
	return [@"LabUtil:  " stringByAppendingString:displayName];
}



#pragma mark -
#pragma mark NSApplication Delegate methods

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	if ([[NSUserDefaults standardUserDefaults] integerForKey:HSWStartupBehaviorKey] == HSWOpenBlankAtStartup) {
		return YES;
	} else {
		return NO;
	}
}

- (void) dealloc {
	[preferencesController release];
//	[openPanel release];
//	[lab release];
	[super dealloc];
}

#pragma mark -
#pragma mark Helper Methods

- (IBAction) showPreferencesPanel:(id)sender {
	if (!preferencesController) {
		preferencesController = [[HSWPrefsController alloc] init];
	}
	
	[preferencesController showWindow:self];
}

- (NSString *)getMessageStringForStudent: (HSWStudent *)student usingFormat:(int)format
{
	// returns a dictionary of all the student's properties
	// email, emailSent, firstName, lastName, fullName, idNumber, note, overridePoints, totalPoints
	
	// problem:  commited values are the ones from the last save: 
	[self saveDocument:nil];
	NSDictionary *vals = [student committedValuesForKeys:nil];
	NSString *result;
	int score= [vals[HSWStudentScore] intValue];
	int total = [[[[self lab] valueForKey:@"assignedToCourse"] valueForKey:HSWTotalPoints] intValue];
	double percent = (score / (double)total) * 100;
	int override;
	double overridePercent;
	NSString *overrideString = nil;
	if (vals[HSWStudentOverrideScore] != nil) {
		override =[vals[HSWStudentOverrideScore] intValue];
		overridePercent = (override / (double)total) * 100;
		overrideString = [NSString stringWithFormat:@"  Score Override by Teacher:  %d / %d = %1.2f%@", override, total, overridePercent, @"%"];
	}
	NSString *scoreString = [NSString stringWithFormat:@"Score:  %d / %d = %1.2f%@", score, total, percent, @"%"];
	NSString *labName = [[self lab] valueForKey:@"name"];
	if (format == HSWHtmlFormat) {
		NSXMLElement *root = [NSXMLElement elementWithName:@"HTML"];
		NSXMLDocument *output = [[NSXMLDocument alloc] initWithRootElement:root];
		[output setDocumentContentKind:NSXMLDocumentHTMLKind];
		[output setMIMEType:@"text/html"];
		NSXMLElement *head = [NSXMLElement elementWithName:@"HEAD"];
		NSXMLElement *meta = [NSXMLElement elementWithName:@"META"];
		[meta addAttribute:[NSXMLNode attributeWithName:@"http-equiv" stringValue:@"Content-Type"]];
		[meta addAttribute:[NSXMLNode attributeWithName:@"content" stringValue:@"text/html"]];
		[head addChild:meta];
		[root addChild:head];
		NSXMLElement *body = [NSXMLElement elementWithName:@"BODY"];
		[root addChild:body];
		NSXMLElement *titleCenter = [[NSXMLElement alloc] initWithName:@"CENTER"];
		NSXMLElement *titleStrong = [[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Lab Grading Report"];
		[titleCenter addChild:titleStrong];
		[body addChild:titleCenter];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:[vals valueForKey:HSWStudentName]]];
		[body addChild:[NSXMLElement elementWithName:@"BR"]];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:labName]];
		[body addChild:[NSXMLElement elementWithName:@"BR"]];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Scoring Information"]];
		NSXMLElement *scoreBlock = [[NSXMLElement alloc] initWithName:@"BLOCKQUOTE"];
		[scoreBlock addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:scoreString]];
		if ([overrideString length] > 0) {
			[scoreBlock addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:overrideString]];			
		}
		[body addChild:scoreBlock];
		NSEnumerator *comments = [[vals valueForKey:HSWLabComments] objectEnumerator];
		NSXMLElement *commentBlock = [[NSXMLElement alloc] initWithName:@"BLOCKQUOTE"];		
		NSString *comment;
		while (comment = [comments nextObject]) {
			[commentBlock addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:comment]];
		}
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Comments"]];
		[body addChild:commentBlock];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Additional Comments:"]];
		[body addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:[vals valueForKey:HSWStudentComment]]];
		result = [output XMLStringWithOptions:NSXMLNodePrettyPrint];
		[output release];
		[titleCenter release];
		[titleStrong release];
		[scoreBlock release];
		[commentBlock release];
	} else if (format == HSWTextFormat) {
		NSString *output = [NSString stringWithFormat:@"Lab Report for %@ \n\nLab Name:  %@\n\nScore Information:\n  %@", [vals valueForKey:HSWStudentName], labName, scoreString];
		if ([overrideString length] > 0) {
			output = [NSString stringWithFormat:@"%@\n%@\n", output, overrideString];
		}
		output = [NSString stringWithFormat:@"  %@\n\nComments:\n", output];
		NSEnumerator *comments = [[vals valueForKey:HSWLabComments] objectEnumerator];
		NSString *comment;
		while (comment = [comments nextObject]) {
			output = [NSString stringWithFormat:@"%@    %@\n", output, comment];
		}
		output = [NSString stringWithFormat:@"%@\nAdditional Comments:\n\n%@\n", output, [vals valueForKey:HSWStudentComment]];
		result = [output copy];
	} else  {
		
	}
	return result;
	
	
}

/*
 getCurrentStudentData
 
 returns an NSDictionary of values
 
 Key					Value
 HSWStudentName		NSString:  First Last names
 HSWStudentEmail		NSString:  Email address
 HSWLabName			NSString:  name of lab
 HSWTotalPoints		int:	point value of lab
 HSWStudentScore		int:	student's score on lab
 HSWLabComments		NSArray:  array of NSString.  each string is a single comment
 
 */

- (NSDictionary *)getCurrentStudentData
{
	
	NSMutableDictionary *returnVals = [NSMutableDictionary new];
	HSWStudent *currentStudent = [studentController selectedObjects][0];
	
	[returnVals setValue:[currentStudent valueForKey:@"fullName"] forKey:HSWStudentName];
	[returnVals setValue:[currentStudent valueForKey:@"totalPoints"] forKey:HSWStudentScore];
	[returnVals setValue:[currentStudent valueForKey:@"overridePoints"] forKey:HSWStudentOverrideScore];
	[returnVals setValue:[currentStudent valueForKey:@"email"] forKey:HSWStudentEmail];
	if ([currentStudent valueForKey:@"note"] != nil) {
		[returnVals setValue:[currentStudent valueForKey:@"note"] forKey:HSWStudentComment];				
	} else {
		[returnVals setValue:@"None" forKey:HSWStudentComment];
	}
	
	[returnVals setValue:[[[labController content] valueForKey:@"assignedToCourse"] valueForKey:@"totalPoints"] forKey:HSWTotalPoints];
	[returnVals setValue:[[labController content] valueForKey:@"name"] forKey:HSWLabName];
	
	// find all the selected objects in the rubricGradingController
	NSArray *selectedRubricElements = [rubricGradingController selectedObjects];
	NSEnumerator *enumerator = [selectedRubricElements objectEnumerator];
	HSWRubricElement *value;
	NSMutableArray *comments = [NSMutableArray new];
	while ((value = [enumerator nextObject])) {
		[comments addObject:[value summary]];
	}
	[returnVals setValue:comments forKey:HSWLabComments];
	NSLog(@"%@", [returnVals description]);
	return [returnVals autorelease];
}

- (IBAction)generateHTML:(id)sender
{
	
	NSPasteboard  *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:
	 @[NSStringPboardType] 
               owner:self];
	HSWStudent *currentStudent = [studentController selectedObjects][0];
	[pb setString:[self getMessageStringForStudent:currentStudent usingFormat:HSWHtmlFormat] forType:NSStringPboardType];
//	[pb setString:[self getMessageFormat:HSWHtmlFormat withStudentData:[self getCurrentStudentData]] forType:NSStringPboardType];
	
}

- (NSString *)getMessageFormat:(int)format withStudentData:(NSDictionary *)vals
{
	NSString *result;
	int score= [[vals valueForKey:HSWStudentScore] intValue];
	int total = [[vals valueForKey:HSWTotalPoints] intValue];
	double percent = (score / (double)total) * 100;
	int override;
	double overridePercent;
	NSString *overrideString = nil;
	if ([vals valueForKey:HSWStudentOverrideScore] != nil) {
		override =[[vals valueForKey:HSWStudentOverrideScore] intValue];
		overridePercent = (override / (double)total) * 100;
		overrideString = [NSString stringWithFormat:@"  Score Override by Teacher:  %d / %d = %1.2f%@", override, total, overridePercent, @"%"];
	}
	NSString *scoreString = [NSString stringWithFormat:@"Score:  %d / %d = %1.2f%@", score, total, percent, @"%"];
	if (format == HSWHtmlFormat) {
		NSXMLElement *root = [NSXMLElement elementWithName:@"HTML"];
		NSXMLDocument *output = [[NSXMLDocument alloc] initWithRootElement:root];
		[output setDocumentContentKind:NSXMLDocumentHTMLKind];
		[output setMIMEType:@"text/html"];
		NSXMLElement *head = [NSXMLElement elementWithName:@"HEAD"];
		NSXMLElement *meta = [NSXMLElement elementWithName:@"META"];
		[meta addAttribute:[NSXMLNode attributeWithName:@"http-equiv" stringValue:@"Content-Type"]];
		[meta addAttribute:[NSXMLNode attributeWithName:@"content" stringValue:@"text/html"]];
		[head addChild:meta];
		[root addChild:head];
		NSXMLElement *body = [NSXMLElement elementWithName:@"BODY"];
		[root addChild:body];
		NSXMLElement *titleCenter = [[NSXMLElement alloc] initWithName:@"CENTER"];
		NSXMLElement *titleStrong = [[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Lab Grading Report"];
		[titleCenter addChild:titleStrong];
		[body addChild:titleCenter];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:[vals valueForKey:HSWStudentName]]];
		[body addChild:[NSXMLElement elementWithName:@"BR"]];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:[vals valueForKey:HSWLabName]]];
		[body addChild:[NSXMLElement elementWithName:@"BR"]];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Scoring Information"]];
		NSXMLElement *scoreBlock = [[NSXMLElement alloc] initWithName:@"BLOCKQUOTE"];
		[scoreBlock addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:scoreString]];
		if ([overrideString length] > 0) {
			[scoreBlock addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:overrideString]];			
		}
		[body addChild:scoreBlock];
		NSEnumerator *comments = [[vals valueForKey:HSWLabComments] objectEnumerator];
		NSXMLElement *commentBlock = [[NSXMLElement alloc] initWithName:@"BLOCKQUOTE"];		
		NSString *comment;
		while (comment = [comments nextObject]) {
			[commentBlock addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:comment]];
		}
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Comments"]];
		[body addChild:commentBlock];
		[body addChild:[[NSXMLElement alloc] initWithName:@"STRONG" stringValue:@"Additional Comments:"]];
		[body addChild:[[NSXMLElement alloc] initWithName:@"P" stringValue:[vals valueForKey:HSWStudentComment]]];
		result = [output XMLStringWithOptions:NSXMLNodePrettyPrint];
		[output release];
		[titleCenter release];
		[titleStrong release];
		[scoreBlock release];
		[commentBlock release];
	} else if (format == HSWTextFormat) {
		NSString *output = [NSString stringWithFormat:@"Lab Report for %@ \n\nLab Name:  %@\n\nScore Information:\n  %@", [vals valueForKey:HSWStudentName], [vals valueForKey:HSWLabName], scoreString];
		if ([overrideString length] > 0) {
			output = [NSString stringWithFormat:@"%@\n%@\n", output, overrideString];
		}
		output = [NSString stringWithFormat:@"  %@\n\nComments:\n", output];
		NSEnumerator *comments = [[vals valueForKey:HSWLabComments] objectEnumerator];
		NSString *comment;
		while (comment = [comments nextObject]) {
			output = [NSString stringWithFormat:@"%@    %@\n", output, comment];
		}
		output = [NSString stringWithFormat:@"%@\nAdditional Comments:\n\n%@\n", output, [vals valueForKey:HSWStudentComment]];
		result = [output copy];
	} else  {
		
	}
	return result;
}

- (IBAction )generateText:(id)sender
{
	NSPasteboard  *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:
	 @[NSStringPboardType] 
               owner:self];
//	[pb setString:[self getMessageFormat:HSWTextFormat withStudentData:[self getCurrentStudentData]] forType:NSStringPboardType];
	HSWStudent *currentStudent = [studentController selectedObjects][0];
	[pb setString:[self getMessageStringForStudent:currentStudent usingFormat:HSWTextFormat] forType:NSStringPboardType];

}

//- (IBAction) emailSelected:(id)sender
//{
//	HSWStudent *currentStudent = [[studentController selectedObjects] objectAtIndex:0];
//	HSWPantomimeSMTP *emailer = [[HSWPantomimeSMTP alloc] initWithServer:@"smtp.gmail.com"
//																	port:465
//															   mechanism:@"LOGIN"
//																  useSSL:YES
//																userName:@"bhgray@gmail.com"
//																password:@"ph0ebe1s"];
//	[emailer setFrom:@"bhgray@gmail.com"];
//	[emailer setCC:@"bhgray@gmail.com"];
//	NSMutableArray *theMessages = [[[NSMutableArray alloc] init] autorelease];
//	NSMutableDictionary *aMessage = [[[NSMutableDictionary alloc] init] autorelease];
//	[aMessage setObject:[currentStudent valueForKey:@"email"] forKey:HSWMessageToKey];
//	[aMessage setObject:@"Lab Scoring Information" forKey:HSWMessageSubjectKey];
//	[aMessage setObject:[self getMessageStringForStudent:currentStudent usingFormat:HSWTextFormat] forKey:HSWMessageTextKey];
//	[aMessage setObject:[self getMessageStringForStudent:currentStudent usingFormat:HSWHtmlFormat] forKey:HSWMessageHTMLKey];
//	[theMessages addObject:aMessage];
//	[emailer setMessages:theMessages];
//
//	[emailer sendAll:nil];
//	[currentStudent setValue:[NSNumber numberWithBool:YES] forKey:@"emailSent"];
//}

//- (IBAction) emailAll:(id)sender
//{
//	
//	
//	NSDictionary *vals = [[self getCurrentStudentData] retain];
//	HSWStudent *currentStudent = [[studentController selectedObjects] objectAtIndex:0];
//	HSWPantomimeSMTP *emailer = [[HSWPantomimeSMTP alloc] initWithServer:@"smtp.gmail.com"
//																	port:465
//															   mechanism:@"LOGIN"
//																  useSSL:YES
//																userName:@"bhgray@gmail.com"
//																password:@"ph0ebe1s"];
//	[emailer setFrom:@"bhgray@gmail.com"];
//	[emailer setCC:@"bhgray@gmail.com"];
//	NSMutableArray *theMessages = [[[NSMutableArray alloc] init] autorelease];
//	NSMutableDictionary *aMessage = [[[NSMutableDictionary alloc] init] autorelease];
//	[aMessage setObject:[vals objectForKey:HSWStudentEmail] forKey:HSWMessageToKey];
//	[aMessage setObject:@"Lab Scoring Information" forKey:HSWMessageSubjectKey];
//	[aMessage setObject:[self getMessageFormat:HSWTextFormat withStudentData:[self getCurrentStudentData]] forKey:HSWMessageTextKey];
//	[aMessage setObject:[self getMessageFormat:HSWHtmlFormat withStudentData:[self getCurrentStudentData]] forKey:HSWMessageHTMLKey];
//	[theMessages addObject:aMessage];
//	[emailer setMessages:theMessages];
//	//	[NSThread detachNewThreadSelector:@selector(sendAll:) toTarget:emailer
//	//						   withObject:nil]; 
//	[emailer sendAll:nil];
//	[currentStudent setValue:[NSNumber numberWithBool:YES] forKey:@"emailSent"];
//}

- (IBAction) resetAll:(id)sender 
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Reset the scores?"];
	[alert setInformativeText:@"Reset scores cannot be restored."];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[ [ self windowControllers ][0] window ] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[alert release];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
		NSMutableSet *students = [[[labController content] valueForKey:@"assignedToCourse"] valueForKey:@"hasRosteredStudents"];
		NSEnumerator *studentEnum = [students objectEnumerator];
		HSWStudent *student;
		
		while ((student = [studentEnum nextObject])) {
			[student setValue:[NSMutableSet set] forKey:@"hasGradeElements"];
			[student setValue:nil forKey:@"overridePoints"];
			[student setValue:nil forKey:@"comment"];
			[student setValue:@NO forKey:@"emailSent"];
		}
    }
}

- (void)copy:sender {
	
	NSArray *selectedObjects = nil;
	HSWDataCopyType type = HSWOtherCopyType;
	NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
	if ([[tabViewItem identifier] caseInsensitiveCompare:@"HSWCourseTab"] == NSOrderedSame) {
		selectedObjects = [studentController selectedObjects];
		type = HSWStudentCopyType;
	} else if ([[tabViewItem identifier] caseInsensitiveCompare:@"HSWGradingProfileTab"] == NSOrderedSame) {
		selectedObjects = [rubricController selectedObjects];
		type = HSWRubricElementCopyType;
	}
    
    unsigned i, count = [selectedObjects count];
    if (count == 0) {
        return;
    }
	
    NSMutableArray *copyObjectsArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *copyStringsArray = [NSMutableArray arrayWithCapacity:count];
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard declareTypes:
	 @[HSWRubricElementPboardType, HSWStudentPboardType, NSStringPboardType]
                              owner:self];
    
	if (type == HSWRubricElementCopyType) {
		HSWRubricElement *theEl;
		for (i = 0; i < count; i++) {
			theEl = (HSWRubricElement *)selectedObjects[i];
			[copyObjectsArray addObject:[theEl dictionaryRepresentation]];
			[copyStringsArray addObject:[theEl summary]];
		}
		NSData *copyData = [NSArchiver archivedDataWithRootObject:copyObjectsArray];
		[generalPasteboard setData:copyData forType:HSWRubricElementPboardType];
	} else if (type == HSWStudentCopyType) {
		HSWRubricElement *theEl;
		for (i = 0; i < count; i++) {
			theEl = (HSWRubricElement *)selectedObjects[i];
			[copyObjectsArray addObject:[theEl dictionaryRepresentation]];
			[copyStringsArray addObject:[theEl summary]];
		}
		NSData *copyData = [NSArchiver archivedDataWithRootObject:copyObjectsArray];
		[generalPasteboard setData:copyData forType:HSWStudentPboardType];
	}
	
    [generalPasteboard setString:
	 [copyStringsArray componentsJoinedByString:@"\n"]
                         forType:NSStringPboardType];
}

- (void)paste:sender {
	
	HSWDataCopyType type = HSWOtherCopyType;
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    NSManagedObjectContext *moc = [self managedObjectContext];
	
	NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
	if ([[tabViewItem identifier] caseInsensitiveCompare:@"HSWCourseTab"] == NSOrderedSame) {
		NSData *data = [generalPasteboard dataForType:HSWStudentPboardType];
		if (data == nil) {
			return;
		} 
		type = HSWStudentCopyType;
		NSMutableSet *students = [[[labController content] valueForKey:@"assignedToCourse"] mutableSetValueForKey:@"hasRosteredStudents"];
		NSArray *studentsArray = [NSUnarchiver unarchiveObjectWithData:data];
		
		unsigned i, count = [studentsArray count];
		for (i = 0; i < count; i++) {
			
			HSWStudent *element;
			element = (HSWStudent *)[NSEntityDescription insertNewObjectForEntityForName:@"Student"
																  inManagedObjectContext:moc];
			[element setValuesForKeysWithDictionary:studentsArray[i]];
			[students addObject:element];
		}
	} else if ([[tabViewItem identifier] caseInsensitiveCompare:@"HSWGradingProfileTab"] == NSOrderedSame) {
		NSData *data = [generalPasteboard dataForType:HSWRubricElementPboardType];
		if (data == nil) {
			return;
		}
		type = HSWRubricElementCopyType;
		NSMutableSet *rubricEntries = [[labController content] mutableSetValueForKey:@"hasRubricElements"];
		NSArray *rubricElementsArray = [NSUnarchiver unarchiveObjectWithData:data];
		
		unsigned i, count = [rubricElementsArray count];
		for (i = 0; i < count; i++) {
			
			HSWRubricElement *element;
			element = (HSWRubricElement *)[NSEntityDescription insertNewObjectForEntityForName:@"RubricElement"
																		inManagedObjectContext:moc];
			[element setValuesForKeysWithDictionary:rubricElementsArray[i]];
			[rubricEntries addObject:element];
		}
	}
    
}


#pragma mark -
#pragma mark Toobar Initializers and Delegate

- (void)initializeToolbar 
{ 
    NSToolbar *toolbar = [[NSToolbar alloc] 
						  initWithIdentifier:HSWToolbarIdentifier]; 
    [toolbar setAllowsUserCustomization:YES]; 
    [toolbar setAutosavesConfiguration:YES]; 
    [toolbar setDelegate:self]; 
    [[ [ self windowControllers ][0] window ] setToolbar:toolbar]; 
} 

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted {
    // Required delegate method:  Given an item identifier, this method returns an item 
    // The toolbar will use this method to obtain toolbar items that can be displayed in the customization sheet, or in the toolbar itself 
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	if ([itemIdent isEqual: HSWToolbarHTMLIdentifier])
	{
		[toolbarItem setLabel:@"HTML"];
		[toolbarItem setPaletteLabel: @"HTML"];
		
		// Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties 
		[toolbarItem setToolTip: @"Generate an HTML"];
		[toolbarItem setImage: [NSImage imageNamed: @"html.tiff"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(generateHTML:)];
	} else if ([itemIdent isEqual: HSWToolbarEmailSingleIdentifier])
	{
		[toolbarItem setLabel:@"Email Single"];
		[toolbarItem setPaletteLabel: @"Email Single"];
		
		// Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties 
		[toolbarItem setToolTip: @"Email Selected Result"];
		[toolbarItem setImage: [NSImage imageNamed: @"email.tiff"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(emailSelected:)];
	} else if ([itemIdent isEqual: HSWToolbarEmailAllIdentifier])
	{
		[toolbarItem setLabel:@"Email All"];
		[toolbarItem setPaletteLabel: @"Email All"];
		
		// Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties 
		[toolbarItem setToolTip: @"Email All Results"];
		[toolbarItem setImage: [NSImage imageNamed: @"email.tiff"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(emailAll:)];
	} else if ([itemIdent isEqual: HSWToolbarTextIdentifier])
	{
		[toolbarItem setLabel:@"Text"];
		[toolbarItem setPaletteLabel: @"Text"];
		
		// Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties 
		[toolbarItem setToolTip: @"Generate a Text"];
		[toolbarItem setImage: [NSImage imageNamed: @"text.tiff"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(generateText:)];
	} else  if ([itemIdent isEqual: HSWToolbarTestIdentifier])
	{
		[toolbarItem setLabel:@"Test"];
		[toolbarItem setPaletteLabel: @"Test"];
		
		// Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties 
		[toolbarItem setToolTip: @"Test the Labs"];
		[toolbarItem setImage: [NSImage imageNamed: @"test.tiff"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(testLabs:)];
	} else  if ([itemIdent isEqual: HSWToolbarResetScoresIdentifier])
	{
		[toolbarItem setLabel:@"Reset Scores"];
		[toolbarItem setPaletteLabel: @"Reset Scores"];
		
		// Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties 
		[toolbarItem setToolTip: @"Reset all scores for this Lab"];
		[toolbarItem setImage: [NSImage imageNamed: @"reset.tiff"]];
		
		// Tell the item what message to send when it is clicked 
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(resetAll:)];
	} else
	{	
		// itemIdent refered to a toolbar item that is not provide or supported by us or cocoa 
		// Returning nil will inform the toolbar this kind of item is not supported 
		toolbarItem = nil;
    }
	
    return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    // Required delegate method:  Returns the ordered list of items to be shown in the toolbar by default    
    // If during the toolbar's initialization, no overriding values are found in the user defaults, or if the
    // user chooses to revert to the default items this set will be used 
    return @[HSWToolbarHTMLIdentifier, HSWToolbarTextIdentifier, HSWToolbarEmailSingleIdentifier, HSWToolbarEmailAllIdentifier, HSWToolbarTestIdentifier, HSWToolbarResetScoresIdentifier];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    // Required delegate method:  Returns the list of all allowed items by identifier.  By default, the toolbar 
    // does not assume any items are allowed, even the separator.  So, every allowed item must be explicitly listed   
    // The set of allowed items is used to construct the customization palette 
    return @[HSWToolbarHTMLIdentifier, 
			HSWToolbarTextIdentifier,
			HSWToolbarEmailSingleIdentifier,
			HSWToolbarEmailAllIdentifier,
			HSWToolbarTestIdentifier,
			NSToolbarSeparatorItemIdentifier, 
			NSToolbarFlexibleSpaceItemIdentifier, 
			NSToolbarCustomizeToolbarItemIdentifier,
			NSToolbarSpaceItemIdentifier,
			HSWToolbarResetScoresIdentifier];
}


- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	BOOL ret = NO;
	
	SEL	theAction = [theItem action];
	if ([[[tabView selectedTabViewItem] identifier] caseInsensitiveCompare:@"HSWResultsTab"] == NSOrderedSame) 
	{
		// TODO:  should also test for data suitable for creating reports....
		if (theAction == @selector(generateHTML:)) 
		{
			ret = YES;
		}
		
		if (theAction == @selector(generateText:)) 
		{
			ret = YES;
		}
		
		if (theAction == @selector(emailSelected:))
		{
			if ([studentController selectionIndex] == NSNotFound) {
				ret = NO;
			} else {
				ret = YES;
			}
		}
		
		if (theAction == @selector(emailAll:))
		{
			ret = YES;
		}

		if (theAction == @selector(resetAll:)) 
		{
			return YES;
		}
	} else if ([[[tabView selectedTabViewItem] identifier] caseInsensitiveCompare:@"HSWTestProfileTab"] == NSOrderedSame) 
	{
		// TODO:  should also test for data suitable for testing
		if (theAction == @selector(testLabs:)) 
		{
			ret = YES;
		}
	}
	
    return ret;
}

#pragma mark -
#pragma mark Import Students Methods

- (IBAction)chooseStudentRootDir:(id)sender {
	openPanel = [NSOpenPanel openPanel];
	[openPanel setAccessoryView:accessoryViewFlagBox];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setPrompt:@"Choose folder"]; // Should be localized
	[openPanel setCanChooseFiles:NO];
	
	[accessoryViewFlagBox retain];
	
    // Run the open panel
    [openPanel beginSheetForDirectory:nil
								 file:nil
								types: nil
					   modalForWindow: [self windowForSheet]
						modalDelegate:self
					   didEndSelector:
	 @selector(filePanelDidEnd:returnCode:contextInfo:)
						  contextInfo:NULL];
}

-(void)filePanelDidEnd:(NSOpenPanel*)sheet
            returnCode:(int)returnCode
           contextInfo:(void*)contextInfo {
	
	if (returnCode == 0) return; // user did not click OK
	[self setRootDirectoryFromFilename:[sheet filename]];
	if (importStudentsFlag) {
		[self importStudentsFromFolders];
	}
}

- (IBAction) setImportStudentsFromFoldersFlag:(id)sender {
	importStudentsFlag = [sender state];
	[importStudentsOverwriteCheckBox setEnabled:importStudentsFlag];
}
	
- (IBAction) setImportStudentsOverwriteFlag:(id)sender {
	importStudentsOverwriteFlag = [sender state];
}
	
	/*
	 
	 Method is called from filePanelDidEnd
	 User has chosen a new value for the studentRootDir in the Lab object
	 
	 subdirs of that value should be in the format
	 
	 id-lastname-firstname-email
	 
	 we should be able to change this in preferences
	 
	 */
	
- (void) importStudentsFromFolders 
	{
		//	NSLog(@"importStudentsFromFolders called");
		NSArray *subpaths = nil;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *studentRootDir = [[labController content] valueForKey:@"studentRootDir"];
		BOOL isDir, valid = [fileManager fileExistsAtPath:studentRootDir isDirectory:&isDir];
		if (valid && isDir) {
			subpaths = [fileManager subpathsAtPath:studentRootDir];	
		}
		
		HSWCourse *theCourse = [[labController content] valueForKey:@"assignedToCourse"];
		NSMutableSet *studentSet = [theCourse mutableSetValueForKey:@"hasRosteredStudents"];
		if (importStudentsOverwriteFlag) {
			[studentSet removeAllObjects];
		}
		
		// reset the GUI
		importStudentsFlag = NO;
		importStudentsOverwriteFlag = NO;
		[importStudentsCheckBox setState:0];
		[importStudentsOverwriteCheckBox setEnabled:NO];
		[importStudentsOverwriteCheckBox setState:0];
		
		NSString *fullPath;
		NSArray *studentComponents;
		HSWStudent *student;
		int i;
		for (i = 0; i < [subpaths count]; i++) {
			fullPath = [studentRootDir stringByAppendingPathComponent:subpaths[i]];
			BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
			if (valid && isDir) {
				studentComponents = [subpaths[i] componentsSeparatedByString:@"-"];
				student = [NSEntityDescription insertNewObjectForEntityForName:@"Student"
														inManagedObjectContext:[self managedObjectContext]];
				[student setValue:studentComponents[0] forKey:@"idNumber"];
				[student setValue:studentComponents[1] forKey:@"firstName"];
				[student setValue:studentComponents[2] forKey:@"lastName"];
				[student setValue:studentComponents[3] forKey:@"email"];
				[student setValue:theCourse forKey:@"enrolledInCourse"];
				[studentSet addObject:student];
			}
		}
		[theCourse setValue:studentSet forKey:@"hasRosteredStudents"];
		[[self managedObjectContext] processPendingChanges];
//		[studentsTableView reloadData];
		
	}
	
- (void) setRootDirectoryFromFilename:(NSString *)fileName 
{
	HSWLab *theLab = [labController content];
	[theLab setValue:fileName forKey:@"studentRootDir"];
	[rootDirField setStringValue:fileName];
//	[HSWFileSystemItem setRootItem:fileName];
//	studentDirsDataSource = [[HSWStudentDirsDataSource alloc] init];
//	[studentDirsView setDelegate:studentDirsDataSource];
//	[studentDirsView setDataSource:studentDirsDataSource];
//	[studentDirsView reloadData];
//	[rootDirField setStringValue:[[HSWFileSystemItem rootItem] fullPath]];
}

@end
