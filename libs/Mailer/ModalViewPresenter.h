//
//  ModalViewPresenter.h
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

#import <UIKit/UIKit.h>
#import "SynthesizeSingleton.h"


/**
 * Presents a modal view controller based off the first view in the key window.
 */
@interface ModalViewPresenter : NSObject
{
	/** A dummy view controller to present modal views. */
	UIViewController* dummyViewController;
	
	UIView* dummyView;
	
	UIViewController* modalViewController;
}

/** Make this class into a singleton. */
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ModalViewPresenter);

/** The currently displayed modal view controller. */
@property(nonatomic,readonly) UIViewController *modalViewController;

/** Display another view controller as a modal child. Uses a vertical sheet transition if animated.
 */
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;

/** Dismiss the current modal child. Uses a vertical sheet transition if animated.
 */
- (void)dismissModalViewControllerAnimated:(BOOL)animated;


@end
