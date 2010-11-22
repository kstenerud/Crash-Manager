//
//  CrashManagerDemoAppDelegate.m
//  CrashManager
//
//  Created by Karl Stenerud on 10-09-13.
//

#import "CrashManagerDemoAppDelegate.h"
#import "CrashManagerDemoViewController.h"
#import "CrashManager.h"
#import "StackTracer.h"

@implementation CrashManagerDemoAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	// Install Crash Manager
	[[CrashManager sharedInstance] manageCrashes];
	[[CrashManager sharedInstance] setCrashDelegate:self selector:@selector(notifyException:stackTrace:)];

    return YES;
}

- (void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}

- (void) notifyException:(NSException*) exception stackTrace:(NSArray*) stackTrace
{
	// Oh no!  We crashed!
	// Time to output some stuff to the console.
	
	// Note: Any EXC_BAD_ACCESS crashes (such as accessing a deallocated object) will
	// cause the app to close stdout, so you won't see this trace in such a case.

	NSLog(@"Exception:\n%@\n", exception);

	NSLog(@"Full Trace:\n%@\n", [[StackTracer sharedInstance] printableTrace:stackTrace]);

	NSArray* intelligentTrace = [[StackTracer sharedInstance] intelligentTrace:stackTrace];
	NSLog(@"Condensed Intelligent Trace:\n%@", [[StackTracer sharedInstance] condensedPrintableTrace:intelligentTrace]);
}

@end
