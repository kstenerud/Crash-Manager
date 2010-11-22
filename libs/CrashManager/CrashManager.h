//
//  CrashManager.h
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

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"


/**
 * Manages any crashes that occur while the app is running.
 * If a crash occurs while CrashManager is managing crashes, it will write
 * a crash report to a file, allow a user-defined delegate to do some more processing,
 * then let the application finish crashing.
 */
@interface CrashManager : NSObject
{
	/** The full path to the error report that this manager will write to. */
	NSString* errorReportPath;

	/** The delegate to inform when a crash occurs (can be nil). */
	id delegate;

	/** The selector to call on the delegate. */
	SEL callbackSelector;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(CrashManager);

/**
 * Start managing crashes.
 */
- (void) manageCrashes;

/**
 * Stop managing crashes.
 */
- (void) stopManagingCrashes;

/** The error report's path.
 * Note: If you set this to a value that doesn't start with "/", it will
 *       be expanded to a full path relative to the Documents directory.
 */
@property(readwrite,nonatomic,retain) NSString* errorReportPath;

/** The error report.  If there is no report, this will be nil. */
@property(readonly,nonatomic) NSString* errorReport;

/** If true, there is an error report present. */
@property(readonly,nonatomic) bool errorReportPresent;

/**
 * Delete the error report (if any).
 */
- (void) deleteErrorReport;

/**
 * Set the delegate and selector to call when a crash occurs.
 * The selector must take an NSException* and NSArray* parameter like so: <br>
 * - (void) notifyException:(NSException*) exception stackTrace:(NSArray*) stackTrace <br>
 * stackTrace will be an array of StackTraceEntry.
 *
 * @param delegate The delegate to call.
 * @param selector The selector to invoke.
 */
- (void) setCrashDelegate:(id) delegate selector:(SEL) selector;


@end


