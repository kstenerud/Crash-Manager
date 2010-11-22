//
//  Mailer.m
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

#import "Mailer.h"
#import "ModalViewPresenter.h"


@implementation Mailer

SYNTHESIZE_SINGLETON_FOR_CLASS(Mailer);

- (void) sendMailTo:(NSString*) recipient
			subject:(NSString*) subject
			message:(NSString*) message
			 isHtml:(bool) isHtml
{
	NSArray* recipients = nil == recipient ? nil : [NSArray arrayWithObject:recipient];
	[self sendMailToRecipients:recipients
					   subject:subject
					   message:message
						isHtml:isHtml
				  resultTarget:nil
					  selector:nil];
}

- (void) sendMailTo:(NSString*) recipient
			subject:(NSString*) subject
			message:(NSString*) message
			 isHtml:(bool) isHtml
	   resultTarget:(id) target
		   selector:(SEL) selector
{
	NSArray* recipients = nil == recipient ? nil : [NSArray arrayWithObject:recipient];
	[self sendMailToRecipients:recipients
					   subject:subject
					   message:message
						isHtml:isHtml
				  resultTarget:target
					  selector:selector];
}

- (void) sendMailToRecipients:(NSArray*) recipients
					  subject:(NSString*) subject
					  message:(NSString*) message
					   isHtml:(bool) isHtml
{
	[self sendMailToRecipients:recipients
					   subject:subject
					   message:message
						isHtml:isHtml
				  resultTarget:nil
					  selector:nil];
}

- (void) sendMailToRecipients:(NSArray*) recipients
					  subject:(NSString*) subject
					  message:(NSString*) message
					   isHtml:(bool) isHtml
				 resultTarget:(id) target
					 selector:(SEL) selector
{
	mailResultTarget = target;
	mailResultSelector = selector;
	MFMailComposeViewController* mailController = [[[MFMailComposeViewController alloc] init] autorelease];
	mailController.mailComposeDelegate = self;
	
	if(nil != recipients)
	{
		[mailController setToRecipients:recipients];
	}
	if(nil != subject)
	{
		[mailController setSubject:subject];
	}
	if(nil != message)
	{
		[mailController setMessageBody:message isHTML:isHtml];
	}
	
	[[ModalViewPresenter sharedInstance] presentModalViewController:mailController animated:YES];
}

- (void) mailComposeController:(MFMailComposeViewController*)mailController
		   didFinishWithResult:(MFMailComposeResult)result
						 error:(NSError*)error
{
	[[ModalViewPresenter sharedInstance] dismissModalViewControllerAnimated:YES];

	// Inform the delegate.
	[mailResultTarget performSelector:mailResultSelector
						   withObject:[MailComposeResult resultWithResult:result error:error]];
}


@end

@implementation MailComposeResult

+ (id) resultWithResult:(MFMailComposeResult) result error:(NSError*) error
{
	return [[[self alloc] initWithResult:result error:error] autorelease];
}

- (id) initWithResult:(MFMailComposeResult) resultIn error:(NSError*) errorIn
{
	if(nil != (self = [super init]))
	{
		result = resultIn;
		error = [errorIn retain];
	}
	return self;
}

- (void) dealloc
{
	[error release];
	[super dealloc];
}

@synthesize result;
@synthesize error;

@end

