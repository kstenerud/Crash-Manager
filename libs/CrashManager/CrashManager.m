//
//  CrashManager.m
//  MouseMadness
//
//  Created by Karl Stenerud on 10-02-16.
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

#import "CrashManager.h"
#include <unistd.h>
#import "StackTracer.h"
#import <UIKit/UIKit.h>


/** Maximum number of stack frames to capture. */
#define kStackFramesToCapture 40

/** The default file to store error reports to. */
#define kDefaultReportFilename @"error_report.txt"

/** The exception name to use for raised signals. */
#define kSignalRaisedExceptionName @"SignalRaisedException"


@interface CrashManager (Private)

/**
 * Called automatically to handle an exception.
 *
 * @param exception The exception that was raised.
 * @param stackTrace The stack trace.
 */
- (void) handleException:(NSException*) exception stackTrace:(NSArray*) stackTrace;

/**
 * Called automatically to handle a raised signal.
 *
 * @param signal The signal that was raised.
 * @param stackTrace The stack trace.
 */
- (void) handleSignal:(int) signal stackTrace:(NSArray*) stackTrace;

/**
 * Get the name of a signal.
 *
 * @param signal The signal to get a name for.
 * @return The name of the signal.
 */
- (NSString*) signalName:(int) signal;

/**
 * Store an exception and stack trace to disk.
 * It will be stored to the file specified in reportFilename.
 *
 * @param exception The exception to store.
 * @param stackTrace The stack trace to store.
 */
- (void) storeErrorReport:(NSException*) exception stackTrace:(NSArray*) stackTrace;

@end


/**
 * Install the exception and signal handlers.
 */
static void installHandlers();

/**
 * Remove the exception and signal handlers.
 */
static void removeHandlers();

/**
 * Exception handler.
 * Sets up an appropriate environment and then calls CrashManager to
 * deal with the exception.
 *
 * @param exception The exception that was raised.
 */
static void handleException(NSException* exception);

/**
 * Signal handler.
 * Sets up an appropriate environment and then calls CrashManager to
 * deal with the signal.
 *
 * @param exception The exception that was raised.
 */
static void handleSignal(int signal);



static void installHandlers()
{
	NSSetUncaughtExceptionHandler(&handleException);
	signal(SIGILL, handleSignal);
	signal(SIGABRT, handleSignal);
	signal(SIGFPE, handleSignal);
	signal(SIGBUS, handleSignal);
	signal(SIGSEGV, handleSignal);
	signal(SIGSYS, handleSignal);
	signal(SIGPIPE, handleSignal);
}

static void removeHandlers()
{
	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGILL, SIG_DFL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGSYS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
}

static void handleException(NSException* exception)
{
	removeHandlers();
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSArray* stackTrace = [[StackTracer sharedInstance] generateTraceWithMaxEntries:kStackFramesToCapture];
	[[CrashManager sharedInstance] handleException:exception stackTrace:stackTrace];
	
	[pool drain];
	[exception raise];
}

static void handleSignal(int signal)
{
	removeHandlers();
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSArray* stackTrace = [[StackTracer sharedInstance] generateTraceWithMaxEntries:kStackFramesToCapture];
	[[CrashManager sharedInstance] handleSignal:signal stackTrace:stackTrace];
	
	[pool drain];
	// Note: A signal doesn't need to be re-raised like an exception does.
}


@implementation CrashManager


SYNTHESIZE_SINGLETON_FOR_CLASS(CrashManager);

- (id) init
{
	if(nil != (self = [super init]))
	{
		self.errorReportPath = kDefaultReportFilename;
	}
	return self;
}

- (void) dealloc
{
	[errorReportPath release];
	[super dealloc];
}

- (void) setCrashDelegate:(id) delegateIn selector:(SEL) selectorIn
{
	delegate = delegateIn;
	callbackSelector = selectorIn;
}

- (void) manageCrashes
{
	installHandlers();
}

- (void) stopManagingCrashes
{
	removeHandlers();
}

- (NSString*) errorReportPath
{
	return errorReportPath;
}

- (void) setErrorReportPath:(NSString*) filename
{
	if([filename characterAtIndex:0] != '/')
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* dir = [paths objectAtIndex:0];
		errorReportPath = [[dir stringByAppendingPathComponent:filename] retain];
	}
	else
	{
		errorReportPath = [filename retain];
	}
	
}

- (bool) errorReportPresent
{
	return [[NSFileManager defaultManager] fileExistsAtPath:errorReportPath];
}

- (NSString*) errorReport
{
	NSError *error = nil;
	return [NSString stringWithContentsOfFile:errorReportPath encoding:NSUTF8StringEncoding error:&error];
}

- (void) deleteErrorReport
{
	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:errorReportPath error:&error];
	if(nil != error)
	{
		NSLog(@"Warning: %s: Could not delete %@: %@", __PRETTY_FUNCTION__, errorReportPath, error);
	}
}

- (void) handleException:(NSException*) exception stackTrace:(NSArray*) stackTrace
{
	[self storeErrorReport:exception stackTrace:stackTrace];
	[delegate performSelector:callbackSelector withObject:exception withObject:stackTrace];
}

- (void) handleSignal:(int) signal stackTrace:(NSArray*) stackTrace
{
	NSException* exception = [NSException exceptionWithName:kSignalRaisedExceptionName
													 reason:[self signalName:signal]
												   userInfo:nil];
	[self storeErrorReport:exception stackTrace:stackTrace];
	[delegate performSelector:callbackSelector withObject:exception withObject:stackTrace];
}

- (void) storeErrorReport:(NSException*) exception stackTrace:(NSArray*) stackTrace
{
	NSString* data = [NSString stringWithFormat:@"App: %@\nVersion: %@\nID: %@\n%@: %@\n%@",
					  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
					  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
					  [UIDevice currentDevice].uniqueIdentifier,
					  [exception name],
					  [exception reason],
					  [[StackTracer sharedInstance] printableTrace:stackTrace]];
	[data writeToFile:errorReportPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString*) signalName:(int) signal
{
	switch(signal)
	{
		case SIGABRT:
			return @"Abort";
		case SIGILL:
			return @"Illegal Instruction";
		case SIGSEGV:
			return @"Segmentation Fault";
		case SIGFPE:
			return @"Floating Point Error";
		case SIGBUS:
			return @"Bus Error";
		case SIGPIPE:
			return @"Broken Pipe";
		default:
			return [NSString stringWithFormat:@"Unknown Signal (%d)", signal];
	}
}

@end
