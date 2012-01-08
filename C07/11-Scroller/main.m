/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
    UIImageView *imageView;
    UIScrollView *scrollView;
}
@end

@implementation TestBedViewController

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // 指定誰要被縮放
    return imageView;
}

- (void) viewDidAppear:(BOOL)animated
{
    scrollView.frame = self.view.bounds;
    scrollView.center = CGRectGetCenter(self.view.bounds);
    
    if (imageView.image)
    {
        float scalex = scrollView.frame.size.width / imageView.image.size.width;
        float scaley = scrollView.frame.size.height / imageView.image.size.height;
        scrollView.zoomScale = MIN(scalex, scaley);
        scrollView.minimumZoomScale = MIN(scalex, scaley);
    }
}

- (void) viewDidLayoutSubviews
{
    [self viewDidAppear:NO];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // 建立捲動視圖
    scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 4.0f;
    RESIZABLE(scrollView);
    [self.view addSubview:scrollView];
    
    // 建立內嵌的圖像視圖
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeCenter;
    [scrollView addSubview:imageView];
    
    // 使用操作佇列以非同步方式載入資料
    NSString *map = @"http://maps.weather.com/images/maps/current/curwx_720x486.jpg";
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:
     ^{
         // 載入氣象資料
         NSURL *weatherURL = [NSURL URLWithString:map];
         NSData *imageData = [NSData dataWithContentsOfURL:weatherURL];
         
         // 使用主佇列在主緒程裡更新圖像
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             // 下載圖像資料，設定圖像
             UIImage *weatherImage = [UIImage imageWithData:imageData];
             imageView.userInteractionEnabled = YES;
             imageView.image = weatherImage;
             imageView.frame = (CGRect){.size = weatherImage.size};
             
             // 更動捲動視圖的縮放比
             float scalex = scrollView.frame.size.width / weatherImage.size.width;
             float scaley = scrollView.frame.size.height / weatherImage.size.height;
             scrollView.zoomScale = MIN(scalex, scaley);
             scrollView.minimumZoomScale = MIN(scalex, scaley);
             scrollView.contentSize = weatherImage.size;
         }];
     }];
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