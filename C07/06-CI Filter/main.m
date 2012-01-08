/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "Geometry.h"
#import "UIImage-Utilities.h"
#import "Orientation.h"
#import "CameraImageHelper.h"

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
    
    BOOL useFilter;
}
@end

@implementation TestBedViewController

// 切換相機
- (void) switch: (id) sender
{
    [helper switchCameras];
}

- (void) toggleFilter: (id) sender
{
    useFilter = !useFilter;
}

// 每秒抓10次圖像資料，根據狀況套用濾鏡，並顯示結果
- (void) snap: (NSTimer *) timer
{
    UIImageOrientation orientation = currentImageOrientation(helper.isUsingFrontCamera, NO);
    if (useFilter)
    {
        // 建立褐色濾鏡，強度75%
        CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"
                                           keysAndValues: @"inputImage", helper.ciImage, nil];
        [sepiaFilter setDefaults];  
        [sepiaFilter setValue:[NSNumber numberWithFloat:0.75f] forKey:@"inputIntensity"];
		
        // 套用濾鏡並顯示結果
        CIImage *sepiaImage = [sepiaFilter valueForKey:kCIOutputImageKey];
        if (sepiaImage)
            imageView.image = [UIImage imageWithCIImage:sepiaImage orientation:orientation];
        else NSLog(@"Missing sepia image");
    }
    else
        imageView.image = [UIImage imageWithCIImage:helper.ciImage orientation:orientation];
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
    
    // 加入基本功能
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switch:));
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Toggle Filter", @selector(toggleFilter:));
        
    // 建立圖像視圖以顯示結果
    imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    RESIZABLE(imageView);
    [self.view addSubview:imageView];

    // 建立新的相機操作時域
    helper = [CameraImageHelper helperWithCamera:kCameraFront];
    [helper startRunningSession];
    
    // 每秒更新十次
    [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(snap:) userInfo:nil repeats:YES];    
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