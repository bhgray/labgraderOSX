//
//  HSWPantomimeSMTP.m
//  LabUtilv9
//
//  Created by Brent Gray on 10/17/07.
//  Copyright 2007 Havalina Software Works. All rights reserved.
//

#import "HSWPantomimeSMTP.h"

NSString *HSWMessageToKey = @"HSWMessageToKey";
NSString *HSWMessageSubjectKey = @"HSWMessageSubjectKey";
NSString *HSWMessageHTMLKey = @"HSWMessageHTMLKey";
NSString *HSWMessageTextKey = @"HSWMessageTextKey";



@implementation HSWPantomimeSMTP

- (id) initWithServer:(NSString *)serverValue
				port:(int)portValue
			mechanism:(NSString *)mechanismValue
				useSSL:(BOOL)sslValue
			userName:(NSString *)userNameValue
			password:(NSString *)passwordValue
{
	if (self = [super init]) {
		[self setServer:serverValue];
		[self setPort:portValue];
		[self setMechanism:mechanismValue];
		[self setUserName:userNameValue];
		[self setPassword:passwordValue];
		[self setUseSSL:sslValue];
	}
	return self;
}

- (void) dealloc {
	[from release];
	[server release];
	[userName release];
	[password release];
	[mechanism release];		// "none" for no auth; or PLAIN, LOGIN, or CRAM-MD5 for auth
	[messages release];
	[_smtp release];
	[super dealloc];
}

- (void)sendAll:(id)object {

	CWInternetAddress *address;
	CWMessage *message;
	CWMIMEMultipart *fullMessage;
	NSDictionary *rawMessageData;
	int i;

	// We initialize our SMTP instance
	_smtp = [[CWSMTP alloc] initWithName: [self server]  port: [self port]];
	[_smtp setDelegate: self];

	for (i = 0; i < [messages count]; i++) {
		rawMessageData = [messages objectAtIndex:i];
		message = [[CWMessage alloc] init];
		[message setContentType:@"multipart/related"];
		[message setSubject:[rawMessageData objectForKey:HSWMessageSubjectKey]];
		// set the FROM header
		address = [[CWInternetAddress alloc] initWithString:[self from]];
		[message setFrom:address];
		RELEASE(address);
		
		// set the TO header
		address = [[CWInternetAddress alloc] initWithString:[rawMessageData objectForKey:HSWMessageToKey]];
		[address setType: PantomimeToRecipient];
		[message addRecipient: address];
		RELEASE(address);
		
		// set the CC header
		address = [[CWInternetAddress alloc] initWithString:[self cc]];
		[address setType: PantomimeCcRecipient];
		[message addRecipient: address];
		RELEASE(address);

		  // We set the Message's Content-Type, encoding and charset
		[message setContentTransferEncoding: PantomimeEncodingNone];
		[message setCharset: @"us-ascii"];
		
		// We set the Message's content
		fullMessage = [[CWMIMEMultipart alloc] init];
		CWPart *messagePart = [[CWPart alloc] init];
		[messagePart setContentType:@"text/html"];
		[CWMIMEUtility setContentFromRawSource:[[rawMessageData objectForKey:HSWMessageHTMLKey] dataUsingEncoding: NSASCIIStringEncoding]
			inPart:messagePart];
		[fullMessage addPart:messagePart];
		messagePart = [[CWPart alloc] init];
		[messagePart setContentType:@"text/plain"];
		[CWMIMEUtility setContentFromRawSource:[[rawMessageData objectForKey:HSWMessageTextKey] dataUsingEncoding: NSASCIIStringEncoding]
			inPart:messagePart];
		[fullMessage addPart:messagePart];
		RELEASE(messagePart);
				
		[message setContent:fullMessage];
		[_smtp setMessage: message];
		RELEASE(fullMessage);
		RELEASE(message);

		NSLog(@"Connecting to the %@ server...", [self server]);
		[_smtp connectInBackgroundAndNotify];
	}
}


#pragma mark -
#pragma mark getters/setters

- (NSString *)from {
	return from;
}

- (void) setFrom:(NSString *)value {
	[value retain];
	[from release];
	from = value;
}

- (NSString *)cc {
	return cc;
}

- (void) setCC:(NSString *)value {
	[value retain];
	[cc release];
	cc = value;
}


- (NSString *)server {
	return server;
}

- (void) setServer:(NSString *)value {
	[value retain];
	[server release];
	server = value;
}

- (int)port {
	return port;
}

- (void) setPort:(int)value {
	port = value;
}

- (int)numberOfMessages {
	return [messages count];
}

/*
		Each message is an NSDictionary with keys:
		
		HSWMessageToKey				//	NSString
		HSWMessageSubjectKey		//	NSString
		HSWMessageHTMLKey			//	NSString
		HSWMessageTextKey			//	NSString

*/

- (NSArray *)messages {
	return messages;
}

- (void)setMessages:(NSArray *)value {
	[value retain];
	[messages release];
	messages = value;
}

- (BOOL)useSSL {
	return useSSL;
}

- (void) setUseSSL:(BOOL)value {
	useSSL = value;
}

- (NSString *)userName {
	return userName;
}

- (void) setUserName:(NSString *)value {
	[value retain];
	[userName release];
	userName = value;
}

- (NSString *)password {
	return password;
}

- (void) setPassword:(NSString *)value {
	[value retain];
	[password release];
	password = value;
}

- (NSString *)mechanism {
	return mechanism;
}

// "none" for no auth; or PLAIN, LOGIN, or CRAM-MD5 for auth
- (void) setMechanism:(NSString *)value {
	if ([value isEqualToString:@"PLAIN"]
		|| [value isEqualToString:@"LOGIN"]
		|| [value isEqualToString:@"CRAM-MD5"]) 
	{
		[value retain];
		[mechanism release];
		mechanism = value;
	} else {
		NSLog(@"Error in setting mechanism.  Value was %@", value);
	}
}

#pragma mark -
#pragma mark Plumbing Code

/*
	Source:  SimpleSMTP example from Pantomime release

*/

//
// This method is automatically called once the SMTP authentication
// has completed. If it has failed, -authenticationFailed: will
// be invoked.
//
- (void) authenticationCompleted: (NSNotification *) theNotification
{
  NSLog(@"Authentication completed! Sending the message...");
  [_smtp sendMessage];
}


//
// This method is automatically called once the SMTP authentication
// has failed. If it has succeeded, -authenticationCompleted: will
// be invoked.
//
- (void) authenticationFailed: (NSNotification *) theNotification
{
  NSLog(@"Authentication failed! Closing the connection...");
  [_smtp close];
}


//
// This method is automatically called when the connection to
// the SMTP server was established.
//
- (void) connectionEstablished: (NSNotification *) theNotification
{
  NSLog(@"Connected!");

  if ([self useSSL])
    {
      NSLog(@"Now starting SSL...");
      [(CWTCPConnection *)[_smtp connection] startSSL];
    }
}


//
// This method is automatically called when the connection to
// the SMTP server was terminated avec invoking -close on the
// SMTP instance.
//
- (void) connectionTerminated: (NSNotification *) theNotification
{
  NSLog(@"Connection closed.");
  RELEASE(_smtp);
//  [NSApp terminate: self];
}


//
// This method is automatically called when the message has been
// successfully sent.
//
- (void) messageSent: (NSNotification *) theNotification
{
  NSLog(@"Sent!\nClosing the connection.");
	[_smtp close];
}

//
// This method is automatically invoked once the SMTP service
// is fully initialized. One can send a message directly (if no
// SMTP authentication is required to relay the mail) or proceed
// with the authentication if needed.
//
- (void) serviceInitialized: (NSNotification *) theNotification
{
  if ([self useSSL])
    {
      NSLog(@"SSL handshaking completed.");
    }

  if ([[self mechanism] isEqualToString: @"none"])
    {
      NSLog(@"Sending the message...");
      [_smtp sendMessage];
    }
  else
    {
      NSLog(@"Available authentication mechanisms: %@", [_smtp supportedMechanisms]);
      [_smtp authenticate: [self userName]  password: [self password]  mechanism: [self mechanism]];
    }
}

//
// This method is invoked once the transaction has been reset. This
// can be useful if one when to send more than one message over
// the same SMTP connection.
//
- (void) transactionResetCompleted: (NSNotification *) theNotification
{
  NSLog(@"Sending the message over the same connection...");
  [_smtp sendMessage];
}


@end
	