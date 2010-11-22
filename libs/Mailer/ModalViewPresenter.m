//
//  ModalViewPresenter.m
//  ObjectiveGems
//
//  Created by Karl Stenerud on 10-09-18.
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

#import "ModalViewPresenter.h"


@implementation ModalViewPresenter

SYNTHESIZE_SINGLETON_FOR_CLASS(ModalViewPresenter);

- (void) dealloc
{
	[dummyViewController release];
	[dummyView release];
	[modalViewController release];
	[super dealloc];
}

@synthesize modalViewController;

- (void) presentModalViewController:(UIViewController*) controller animated:(BOOL) animated
{
	if(nil != modalViewController)
	{
		[self dismissModalViewControllerAnimated:animated];
	}

	modalViewController = [controller retain];
	
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if([[window subviews] count] == 0)
	{
		NSArray* windows = [UIApplication sharedApplication].windows;
		for(int i = [windows count] - 1; i >= 0; i--)
		{
			window = [windows objectAtIndex:i];
			if([[window subviews] count] > 0)
			{
				break;
			}
		}
	}
	
	UIView* view;
	if([[window subviews] count] > 0)
	{
		view = [window.subviews objectAtIndex:[[window subviews] count]-1];
	}
	else
	{
		dummyView = [[UIView alloc] init];
		[[UIApplication sharedApplication].keyWindow addSubview:dummyView];
		view = dummyView;
	}


	// Create a dummy controller to present the controller.
	[dummyViewController release];
	dummyViewController = [[UIViewController alloc] init];
	[dummyViewController setView:view];
	[dummyViewController presentModalViewController:modalViewController animated:animated];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
	// Use the dummy controller to dismiss the controller.
	[dummyViewController becomeFirstResponder];
	[dummyViewController dismissModalViewControllerAnimated:YES];
	[dummyViewController release];
	dummyViewController = nil;
	
	[dummyView removeFromSuperview];
	[dummyView release];
	dummyView = nil;
	
	[modalViewController release];
	modalViewController = nil;
}

@end
