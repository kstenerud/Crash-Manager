//
//  CrashManagerDemoViewController.h
//  CrashManager
//
//  Created by Karl Stenerud on 10-09-13.
//

#import <UIKit/UIKit.h>

@interface CrashManagerDemoViewController : UIViewController
{
	NSString* deallocatedString;
	int zeroDivisor;
}

- (IBAction) onCrash_divByZero;
- (IBAction) onCrash_deallocatedObject;
- (IBAction) onCrash_unimplementedSelector;
- (IBAction) onCrash_outOfBounds;

- (IBAction) onMail;
@end

