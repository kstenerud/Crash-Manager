//
//  Mailer.h
//  ObjectiveGems
//
//  Created by Karl Stenerud on 10-01-19.
//
// Copyright 2010 Karl Stenerud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Note: You are NOT required to make the license available from within your
// iOS application. Including it in your project is sufficient.
//
// Attribution is not required, but appreciated :)
//

#import <MessageUI/MessageUI.h>
#import "SynthesizeSingleton.h"

/**
 * Opens the iPhone's built-in mailer to send an email message.
 * The developer may optionally specify a delegate to inform of the result
 * of the mailing operation (successful or not, the user cancelled, etc).
 */
@interface Mailer : NSObject <MFMailComposeViewControllerDelegate>
{
	/** The target to inform when mailing is complete (or not). */
	id mailResultTarget;

	/** The selector to invoke on the target. */
	SEL mailResultSelector;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(Mailer);

/** Open the mailer with the specified information.
 *
 * @param recipient The recipient's email address (can be nil).
 * @param subject The subject of the message (can be nil).
 * @param message The message body (can be nil).
 * @param isHtml If YES, the message body is to be interpreted as HTML.
 */
- (void) sendMailTo:(NSString*) recipient
			subject:(NSString*) subject
			message:(NSString*) message
			 isHtml:(bool) isHtml;

/** Open the mailer with the specified information.
 *
 * @param recipient The recipient's email address (can be nil).
 * @param subject The subject of the message (can be nil).
 * @param message The message body (can be nil).
 * @param isHtml If YES, the message body is to be interpreted as HTML.
 * @param target The target to inform if the result (can be nil).
 * @param selector The selector to invoke on the target (can be nil if target is nil).
 */
- (void) sendMailTo:(NSString*) recipient
			subject:(NSString*) subject
			message:(NSString*) message
			 isHtml:(bool) isHtml
	   resultTarget:(id) target
		   selector:(SEL) selector;

/** Open the mailer with the specified information.
 *
 * @param recipients The recipients' email addresses (can be nil).
 * @param subject The subject of the message (can be nil).
 * @param message The message body (can be nil).
 * @param isHtml If YES, the message body is to be interpreted as HTML.
 */
- (void) sendMailToRecipients:(NSArray*) recipients
					  subject:(NSString*) subject
					  message:(NSString*) message
					   isHtml:(bool) isHtml;

/** Open the mailer with the specified information.
 *
 * @param recipients The recipients' email addresses (can be nil).
 * @param subject The subject of the message (can be nil).
 * @param message The message body (can be nil).
 * @param isHtml If YES, the message body is to be interpreted as HTML.
 * @param target The target to inform if the result (can be nil).
 * @param selector The selector to invoke on the target (can be nil if target is nil).
 */
- (void) sendMailToRecipients:(NSArray*) recipients
					  subject:(NSString*) subject
					  message:(NSString*) message
					   isHtml:(bool) isHtml
				 resultTarget:(id) target
					 selector:(SEL) selector;

@end


/** Contains information about the result of a mail operation.
 */
@interface MailComposeResult : NSObject
{
	MFMailComposeResult result;
	NSError* error;
}
/** The result of the mailing operation. @see MFMailComposeResult */
@property(readonly,nonatomic) MFMailComposeResult result;

/** The error that occurred, if any (will be nil if no error occurred). */
@property(readonly,nonatomic) NSError* error;

/**
 * Create a mail result.
 *
 * @param result The mail compose result.
 * @param error: The error that occurred, if any.
 */
+ (id) resultWithResult:(MFMailComposeResult) result error:(NSError*) error;

/**
 * Initialize a mail result.
 *
 * @param result The mail compose result.
 * @param error: The error that occurred, if any.
 */
- (id) initWithResult:(MFMailComposeResult) result error:(NSError*) error;

@end
