//
//  CrashManagerDemoAppDelegate.h
//  CrashManager
//
//  Created by Karl Stenerud on 10-09-13.
//

#import <UIKit/UIKit.h>

@class CrashManagerDemoViewController;

@interface CrashManagerDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CrashManagerDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CrashManagerDemoViewController *viewController;

@end

