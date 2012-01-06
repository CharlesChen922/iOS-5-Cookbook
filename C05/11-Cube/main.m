/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "RotatingSegue.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

@interface TestBedViewController : UIViewController
{
    NSArray *childControllers;
    UIView *backsplash;
    UIPageControl *pageControl;
    int vcIndex;
}
@end

@implementation TestBedViewController

// 非正式委派方法
- (void) segueDidComplete
{
    pageControl.currentPage = vcIndex;
}

// 使用自製串場轉換到新視圖
- (void) switchToView: (int) newIndex goingForward: (BOOL) goesForward
{
    if (vcIndex == newIndex) return;
        
    // 指向新控制器的串場
    UIViewController *source = [childControllers objectAtIndex:vcIndex];
    UIViewController *destination = [childControllers objectAtIndex:newIndex];
    RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];  
    segue.goesForward = goesForward;
    segue.delegate = self;    
    [segue perform];
    
    vcIndex = newIndex;
}

// 往前
- (void) progress: (id) sender
{
    int newIndex = ((vcIndex + 1) % childControllers.count);  
    [self switchToView:newIndex goingForward:YES];
}

// 往後
- (void) regress: (id) sender
{
    int newIndex = vcIndex - 1;
    if (newIndex < 0) newIndex = childControllers.count - 1;
    [self switchToView:newIndex goingForward:NO];
}

// 建立主使用介面
- (void) viewDidLoad
{
    // 建立基本的背景
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // 建立一張底圖，支援動畫效果
    backsplash = [[UIView alloc] initWithFrame:CGRectInset(self.view.frame, 50.0f, 50.0f)];
    backsplash.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backsplash];
    
    // 加入頁面視圖控制器
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 4;
    [self.view addSubview:pageControl];
    
    // 從storyboard載入子控制器陣列
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"child" bundle:[NSBundle mainBundle]];
    childControllers = [NSArray arrayWithObjects:
                        [aStoryboard instantiateViewControllerWithIdentifier:@"0"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"1"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"2"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"3"],
                        nil];
    
    UISwipeGestureRecognizer *leftSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(progress:)];
    leftSwiper.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwiper.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:leftSwiper];
    
    UISwipeGestureRecognizer *rightSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(regress:)];
    rightSwiper.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwiper.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:rightSwiper];

    // 將每個項目設定為子視圖控制器，設定標號、位置大小
    for (UIViewController *controller in childControllers)
    {
        controller.view.tag = 1066;
        controller.view.frame = backsplash.bounds;
        [self addChildViewController:controller];
    }

    // 以第一個子控制器初始化場景
    vcIndex = 0;
    UIViewController *controller = (UIViewController *)[childControllers objectAtIndex:0];
    [backsplash addSubview:controller.view];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
     for (UIViewController *controller in childControllers)
          controller.view.frame = backsplash.bounds;
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
    window.rootViewController = tbvc;
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