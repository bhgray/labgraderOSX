//
//  HSWPantomimeSMTP.h
//  LabUtilv9
//
//  Created by Brent Gray on 10/17/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Pantomime/Pantomime.h>

extern NSString *HSWMessageToKey;
extern NSString *HSWMessageSubjectKey;
extern NSString *HSWMessageHTMLKey;
extern NSString *HSWMessageTextKey;

@interface HSWPantomimeSMTP : NSObject {
	NSString *from;
	NSString *server;
	int port;
	bool useSSL;
	NSString *userName;
	NSString *password;
	NSString *mechanism;		// "none" for no auth; or PLAIN, LOGIN, or CRAM-MD5 for auth
	NSArray *messages;
	NSString *cc;
	
@private
    CWSMTP *_smtp;
}

- (id) initWithServer:(NSString *)serverValue
				port:(int)portValue
			mechanism:(NSString *)mechanismValue
				useSSL:(BOOL)sslValue
			userName:(NSString *)userNameValue
			password:(NSString *)passwordValue;
			
- (void)sendAll:(id)object;
- (NSString *)from;
- (void) setFrom:(NSString *)value;
- (NSString *)cc;
- (void) setCC:(NSString *)value;
- (NSString *)server;
- (void) setServer:(NSString *)value;
- (int)port;
- (void) setPort:(int)value;
- (int)numberOfMessages;
- (NSArray *)messages;
- (void)setMessages:(NSArray *)value;
- (BOOL)useSSL;
- (void) setUseSSL:(BOOL)value;
- (NSString *)userName;
- (void) setUserName:(NSString *)value;
- (NSString *)password;
- (void) setPassword:(NSString *)value;
- (NSString *)mechanism;
- (void) setMechanism:(NSString *)value;

@end
