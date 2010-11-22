//
//  StackTracer.h
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
 * Generates and formats stack traces.
 */
@interface StackTracer : NSObject
{
	/** The current application process's name. */
	NSString* processName;
}

/** Make this class into a singleton. */
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(StackTracer);

/**
 * Generate a stack trace with the default maximum entries (currently 40).
 *
 * @return an array of StackTraceEntry.
 */
- (NSArray*) generateTrace;

/**
 * Generate a stack trace with the specified maximum entries.
 *
 * @param maxEntries The maximum number of lines to trace.
 * @return an array of StackTraceEntry.
 */
- (NSArray*) generateTraceWithMaxEntries:(unsigned int) maxEntries;

/**
 * Create an "intelligent" trace from the specified trace.
 * This is designed primarily for stripping out useless trace lines from
 * an exception or signal trace.
 *
 * @param stackTrace The trace to convert (NSArray containing StackTraceEntry).
 * @return An intelligent trace with the useless info stripped.
 */
- (NSArray*) intelligentTrace:(NSArray*) stackTrace;

/**
 * Turn the specified stack trace into a printabe string.
 *
 * @param stackTrace The stack trace to convert (NSArray containing StackTraceEntry).
 * @retun A string representation of the stack trace.
 */
- (NSString*) printableTrace:(NSArray*) stackTrace;

/**
 * Turn the specified stack trace into a condensed printable string.
 * The condensed entries are space separated, and only contain the object class
 * (if any) and the selector call.
 *
 * @param stackTrace The stack trace to convert (NSArray containing StackTraceEntry).
 * @return A condensed string representation of the stack trace.
 */
- (NSString*) condensedPrintableTrace:(NSArray*) stackTrace;

@end



/**
 * A single stack trace entry, recording all information about a stack trace line.
 */
@interface StackTraceEntry: NSObject
{
	unsigned int traceEntryNumber;
	NSString* library;
	unsigned int address;
	NSString* objectClass;
	bool isClassLevelSelector;
	NSString* selectorName;
	int offset;
	NSString* rawEntry;
}
/** This entry's position in the original stack trace. */
@property(readonly,nonatomic) unsigned int traceEntryNumber;

/** Which library, framework, or process the entry is from. */
@property(readonly,nonatomic) NSString* library;

/** The address in memory. */
@property(readonly,nonatomic) unsigned int address;

/** The class of object that made the call. */
@property(readonly,nonatomic) NSString* objectClass;

/** If true, this is a class level selector being called. */
@property(readonly,nonatomic) bool isClassLevelSelector;

/** The selector (or function if it's C) being called. */
@property(readonly,nonatomic) NSString* selectorName;

/** The offset within the function or method. */
@property(readonly,nonatomic) int offset;

/** Create a new stack trace entry from the specified trace line.
 * This line is expected to conform to what backtrace_symbols() returns.
 */
+ (id) entryWithTraceLine:(NSString*) traceLine;

/** Initialize a stack trace entry from the specified trace line.
 * This line is expected to conform to what backtrace_symbols() returns.
 */
- (id) initWithTraceLine:(NSString*) traceLine;

@end
