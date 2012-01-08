/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "Geometry.h"
#import "CameraImageHelper.h"

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
}
@end

@implementation TestBedViewController

// 切換相機
- (void) switch: (id) sender
{
    [helper switchCameras];
}

// 開始或暫停
- (void) toggle: (id) sender
{
    if (helper.session.isRunning)
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Resume", @selector(toggle:));
        [helper stopRunningSession];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pause", @selector(toggle:));
        [helper startRunningSession];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.frame = self.view.bounds;
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) viewDidLayoutSubviews
{
    [helper layoutPreviewInView:imageView];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // 切換相機
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switch:));
    
    // 開始或暫停
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pause", @selector(toggle:));
    
    // 圖像視圖含有即時預覽畫面
    imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.contentMode = UIViewContentModeCenter;
    RESIZABLE(imageView);
    [self.view addSubview:imageView];

    helper = [CameraImageHelper helperWithCamera:kCameraFront];
    [helper startRunningSession];
    [helper embedPreviewInView:imageView];
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
    [application setStatusBarHidden:YES];
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