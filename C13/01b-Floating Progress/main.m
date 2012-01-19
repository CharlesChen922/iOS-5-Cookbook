/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ProgressAlert.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UIViewController
{
    float amount;
}
@end

@implementation TestBedViewController

- (void) update: (id) sender
{
    amount += 0.05f;
    [ProgressAlert setProgress:amount];
    [ProgressAlert setMessage:[NSString stringWithFormat:@"%0.0f%% done", amount * 100]]; // 完成進度百分比

    if (amount > 0.5f)
        [ProgressAlert setTitle:@"Nearly Done..."]; // 幾乎快完成了
    
    if (amount > 1)
    {
        [ProgressAlert dismiss];
        return;
    }
    
    [self performSelector:@selector(update:) withObject:nil afterDelay:0.5f];
}

- (void) action: (id) sender
{
    amount = 0.0f;
    [ProgressAlert presentProgress:amount withText:@"Processing..."]; // 進行中
    [self performSelector:@selector(update:) withObject:nil afterDelay:0.5f];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    
    // 本章後面的範例
    
    // 網路活動指示器
    // [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Badging
    // [[UIApplication sharedApplication] setApplicationIconBadgeNumber:99];
    // [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}