//
//  HSWLabDocument.h
//  LabUtilv10
//
//  Created by Brent Gray on 11/4/07.
//  Copyright Havalina Software Works 2007 . All rights reserved.
//

#define DEBUG YES

#import <Cocoa/Cocoa.h>
#import "HSWLab.h"
#import "HSWCourse.h"
#import "HSWPrefsController.h"

extern NSString *HSWStartupBehaviorKey;
extern NSString *HSWDebugStatusKey;
extern NSString *HSWFragmentsPathKey;
extern NSString *HSWLabUtilShortAppName;

typedef enum _HSWStartupBehavior {
	HSWOpenBlankAtStartup		= 0,
	HSWDoNothingAtStartup		= 1
} HSWStartupBehavior;

typedef enum _HSWDebugStatus {
	HSWGenerateTestingData		= 0,
	HSWNoTestingData			= 1
} HSWDebugStatus;

typedef enum _copyType
{
	HSWStudentCopyType = 0,
	HSWRubricElementCopyType = 1,
	HSWOtherCopyType
} HSWDataCopyType;

typedef enum _emailFormatType {
	HSWHtmlFormat	= 0,
	HSWTextFormat	= 1
} HSWGradingReportFormatType;

static NSString*	HSWToolbarIdentifier 						= @"HSWToolbarIdentifier";
static NSString*	HSWToolbarHTMLIdentifier 					= @"HSWToolbarHTMLIdentifier";
static NSString*	HSWToolbarTextIdentifier 					= @"HSWToolbarTextIdentifier";
static NSString*	HSWToolbarEmailSingleIdentifier				= @"HSWToolbarEmailSingleIdentifier";
static NSString*	HSWToolbarEmailAllIdentifier				= @"HSWToolbarEmailAllIdentifier";
static NSString*	HSWToolbarTestIdentifier 					= @"HSWToolbarTestIdentifier";
static NSString*	HSWToolbarResetScoresIdentifier				= @"HSWToolbarResetScoresIdentifier";

extern NSString*	HSWStudentName;
extern NSString*	HSWLabName;
extern NSString*	HSWStudentOverrideScore;
extern NSString*	HSWStudentEmail;
extern NSString*	HSWTotalPoints;
extern NSString*	HSWStudentScore;
extern NSString*	HSWLabComments;
extern NSString*	HSWStudentComment;

static NSString*	HSWRubricElementPboardType					= @"HSWRubricElementPboardType";
static NSString*	HSWStudentPboardType						= @"HSWStudentPboardType";
static NSString*	HSWAdminAddress								= @"bhgray@gmail.com";

@interface HSWLabDocument : NSPersistentDocument {
	
	// data controllers for user interface
	IBOutlet NSObjectController* labController;
	IBOutlet NSArrayController* rubricController;
	IBOutlet NSArrayController* rubricGradingController;
	IBOutlet NSArrayController* studentController;
	//HSWPrefsController *preferencesController;

	// user interface elements
	IBOutlet NSTabView* tabView;
	IBOutlet NSOutlineView* submissionsDirectoryView;
	NSOpenPanel* openPanel;
	IBOutlet NSBox *accessoryViewFlagBox;
	IBOutlet NSButton *importStudentsCheckBox;
	IBOutlet NSButton *importStudentsOverwriteCheckBox;
	IBOutlet NSTextField *rootDirField;
	
	BOOL importStudentsFlag;
	BOOL importStudentsOverwriteFlag;

	HSWLab* lab;
}

@property (retain) HSWLab* lab;

- (NSString *)getMessageFormat:(int)format withStudentData:(NSDictionary *)vals;
- (void)initializeToolbar;
- (void) importStudentsFromFolders;
- (IBAction)chooseStudentRootDir:(id)sender;
- (IBAction) setImportStudentsFromFoldersFlag:(id)sender;
- (IBAction) setImportStudentsOverwriteFlag:(id)sender;
- (IBAction) showPreferencesPanel:(id)sender;

@end
