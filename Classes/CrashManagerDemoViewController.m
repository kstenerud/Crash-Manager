//
//  CrashManagerDemoViewController.m
//  CrashManager
//
//  Created by Karl Stenerud on 10-09-13.
//

#import "CrashManagerDemoViewController.h"
#import "CrashManager.h"
#import "Mailer.h"

@implementation CrashManagerDemoViewController

- (void) doDivisionByZero
{
	NSLog(@"%d", 10 / zeroDivisor);
}

- (IBAction) onCrash_divByZero
{
	// Note: A raised signal destroys the topmost entry on the stack, so the
	// stack trace will only show onCrash_divByZero, and not doDivisionByZero.
	[self doDivisionByZero];
}

- (IBAction) onCrash_deallocatedObject
{
	// Note: EXC_BAD_ACCESS errors tend to cause the app to close stdout,
	// which means you won't see the trace on your console.
	// It is, however, stored to the error log file.
	NSObject* object = [[NSObject alloc] init];
	[object release];
	NSLog(@"%@", object);
}

- (IBAction) onCrash_outOfBounds
{
	NSArray* array = [NSArray arrayWithObject:[[[NSObject alloc] init] autorelease]];
	NSLog(@"%@", [array objectAtIndex:100]);
}

- (IBAction) onCrash_unimplementedSelector
{
	id notAViewController = [NSData data];
	[notAViewController presentModalViewController:nil animated:NO];
}

- (IBAction) onMail
{
	NSString* errorReport = [CrashManager sharedInstance].errorReport;
	if(nil != errorReport)
	{
		[[Mailer sharedInstance] sendMailTo:nil
									subject:@"Error Report"
									message:errorReport
									 isHtml:NO];
	}
}


@end
