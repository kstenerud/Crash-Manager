//
//  StackTracer.m
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

#import "StackTracer.h"
#include <execinfo.h>
#include <unistd.h>


/** The maximum number of stack trace lines to use if none is specified. */
#define kDefaultMaxEntries 40

@implementation StackTracer

SYNTHESIZE_SINGLETON_FOR_CLASS(StackTracer);

- (id) init
{
	if(nil != (self = [super init]))
	{
		processName = [[[NSProcessInfo processInfo] processName] retain];
	}
	return self;
}

- (void) dealloc
{
	[processName release];
	[super dealloc];
}

- (NSArray*) generateTrace
{
	return [self generateTraceWithMaxEntries:kDefaultMaxEntries];
}

- (NSArray*) generateTraceWithMaxEntries:(unsigned int) maxEntries
{
	// Get the stack trace from the OS.
	void* callstack[maxEntries];
	int numFrames = backtrace(callstack, maxEntries);
	char** symbols = backtrace_symbols(callstack, numFrames);
	
	// Create StackTraceEntries.
	NSMutableArray* stackTrace = [NSMutableArray arrayWithCapacity:numFrames];
	for(int i = 0; i < numFrames; i++)
	{
		[stackTrace addObject:[StackTraceEntry entryWithTraceLine:[NSString stringWithUTF8String:symbols[i]]]];
	}
	
	// symbols was malloc'd by backtrace_symbols() and so we must free it.
	free(symbols);
	
	return stackTrace;
}

- (NSArray*) intelligentTrace:(NSArray*) stackTrace
{	
	int startOffset = 0;

	// Anything with this process name at the start is going to be part of the
	// exception/signal catching.  We skip that.
	for(int i = startOffset; i < [stackTrace count]; i++)
	{
		StackTraceEntry* entry = [stackTrace objectAtIndex:i];
		if(![processName isEqualToString:entry.library])
		{
			startOffset = i;
			break;
		}
	}
	
	// Beneath that is a bunch of runtime error handling stuff.  We skip this as well.
	for(int i = startOffset; i < [stackTrace count]; i++)
	{
		StackTraceEntry* entry = [stackTrace objectAtIndex:i];
		
		if(0xffffffff == entry.address)
		{
			// Signal handler stack trace is useless up to "0xffffffff 0x0 + 4294967295"
			startOffset = i + 1;
			break;
		}
		if([@"__objc_personality_v0" isEqualToString:entry.selectorName])
		{
			// Exception handler stack trace is useless up to "__objc_personality_v0 + 0"
			startOffset = i + 1;
			break;
		}
	}

	// Look for the last point where it was still in our code.
	// If we don't find anything, we'll just use everything past the exception/signal stuff.
	for(int i = startOffset; i < [stackTrace count]; i++)
	{
		StackTraceEntry* entry = [stackTrace objectAtIndex:i];
		// If we reach the "main" function, we've exhausted the stack trace.
		// Since we couldn't find anything, start from the previously calculated starting point.
		if([@"main" isEqualToString:entry.selectorName])
		{
			break;
		}
		
		// If we find something from our own code, use one level higher as the starting point.
		if([processName isEqualToString:entry.library])
		{
			startOffset = i - 1;
			break;
		}
	}
	
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:[stackTrace count] - startOffset];
	for(int i = startOffset; i < [stackTrace count]; i++)
	{
		StackTraceEntry* entry = [stackTrace objectAtIndex:i];
		// We don't care about intermediate forwarding functions.
		if(![@"___forwarding___" isEqualToString:entry.selectorName] &&
		   ![@"_CF_forwarding_prep_0" isEqualToString:entry.selectorName])
		{
			[result addObject:[stackTrace objectAtIndex:i]];
		}
	}
	
	return result;
}


- (NSString*) printableTrace:(NSArray*) stackTrace
{
	NSMutableString* string = [NSMutableString stringWithCapacity:[stackTrace count] * 100];
	for(StackTraceEntry* entry in stackTrace)
	{
		[string appendString:[entry description]];
		[string appendString:@"\n"];
	}
	return string;
}

- (NSString*) condensedPrintableTrace:(NSArray*) stackTrace
{
	NSMutableString* string = [NSMutableString stringWithCapacity:[stackTrace count] * 50];
	bool firstRound = YES;
	for(StackTraceEntry* entry in stackTrace)
	{
		if(firstRound)
		{
			firstRound = NO;
		}
		else
		{
			// Space separated.
			[string appendString:@" "];
		}

		if(nil != entry.objectClass)
		{
			// -[MyClass myMethod:anExtraParameter] or
			// +[MyClass myClassMethod:anExtraParameter]
			NSString* levelPrefix = entry.isClassLevelSelector ? @"+" : @"-";
			[string appendFormat:@"%@[%@ %@]", levelPrefix, entry.objectClass, entry.selectorName];
		}
		else
		{
			// my_c_function
			[string appendFormat:@"%@", entry.selectorName];
		}
	}
	return string;
}

@end



@implementation StackTraceEntry

static NSMutableCharacterSet* objcSymbolSet;

+ (id) entryWithTraceLine:(NSString*) traceLine
{
	return [[[self alloc] initWithTraceLine:traceLine] autorelease];
}

- (id) initWithTraceLine:(NSString*) traceLine
{
	if(nil == objcSymbolSet)
	{
		objcSymbolSet = [[NSMutableCharacterSet alloc] init];
		[objcSymbolSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[objcSymbolSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithRange:NSMakeRange('!', '~' - '!')]];
	}
	
	if(nil != (self = [super init]))
	{
		rawEntry = [traceLine retain];
		
		NSScanner* scanner = [NSScanner scannerWithString:rawEntry];
		
		if(![scanner scanInt:(int*)&traceEntryNumber]) goto done;
		
		if(![scanner scanUpToString:@" 0x" intoString:&library]) goto done;
		
		if(![scanner scanHexInt:&address]) goto done;
		
		if(![scanner scanCharactersFromSet:objcSymbolSet intoString:&selectorName]) goto done;
		if([selectorName length] > 2 && [selectorName characterAtIndex:1] == '[')
		{
			isClassLevelSelector = [selectorName characterAtIndex:0] == '+';
			objectClass = [[selectorName substringFromIndex:2] retain];
			if(![scanner scanUpToString:@"]" intoString:&selectorName]) goto done;
			if(![scanner scanString:@"]" intoString:nil]) goto done;
		}
		
		if(![scanner scanString:@"+" intoString:nil]) goto done;
		
		if(![scanner scanInt:&offset]) goto done;
		
	done:
		if(nil == library)
		{
			library = @"???";
		}
		if(nil == selectorName)
		{
			selectorName = @"???";
		}
		[library retain];
		[objectClass retain];
		[selectorName retain];
	}
	return self;
}

- (void) dealloc
{
	[rawEntry release];
	[library release];
	[objectClass release];
	[selectorName release];
	[super dealloc];
}

@synthesize traceEntryNumber;
@synthesize library;
@synthesize address;
@synthesize objectClass;
@synthesize isClassLevelSelector;
@synthesize selectorName;
@synthesize offset;

- (NSString*) description
{
	return rawEntry;
}

@end
