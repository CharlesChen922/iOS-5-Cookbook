/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "RotatingSegue.h"
#import "ReflectingView.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

@interface TestBedViewController : UIViewController
{
    UINavigationBar *bar;
    UINavigationItem *item;

    NSArray *childControllers;
    ReflectingView *backsplash;
    int vcIndex;
}
@end

@implementation TestBedViewController

// 非正式委派方法，再次啟用列按鈕
- (void) segueDidComplete
{
    item.rightBarButtonItem.enabled = YES;
    item.leftBarButtonItem.enabled = YES;
}

// 使用客製的串場，以過場效果切換到新視圖
- (void) switchToView: (int) newIndex goingForward: (BOOL) goesForward
{
    if (vcIndex == newIndex) return;
    
    // 關閉列按鈕，準備串場
    item.rightBarButtonItem.enabled = NO;
    item.leftBarButtonItem.enabled = NO;    
    
    // 連接新控制器的串場
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

// 建立主介面
- (void) viewDidLoad
{
    // 建立基本的背景
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // 建立底圖、供動畫使用
    backsplash = [[ReflectingView alloc] initWithFrame:CGRectInset(self.view.frame, 100.0f, 150.0f)];
    backsplash.usesGradientOverlay = YES;
    backsplash.frame = CGRectOffset(backsplash.frame, 0.0f, -80.0f);
    backsplash.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backsplash];
    [backsplash setupReflection];
    // [self setupGradient];
    
    // 從storyboard載入子視圖控制器陣列
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"child" bundle:[NSBundle mainBundle]];
    childControllers = [NSArray arrayWithObjects:
                        [aStoryboard instantiateViewControllerWithIdentifier:@"0"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"1"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"2"],
                        nil];

    // 設定標號與frame
    for (UIViewController *controller in childControllers)
    {
        controller.view.tag = 1066;
        controller.view.frame = backsplash.bounds;
        [self addChildViewController:controller];
    }

    // 以第一子控制器初始化場景
    vcIndex = 0;
    UIViewController *controller = (UIViewController *)[childControllers objectAtIndex:0];
    [backsplash addSubview:controller.view];

    // 建立導覽項目
    item = [[UINavigationItem alloc] initWithTitle:@"Custom Container"];
    item.leftBarButtonItem = BARBUTTON(@"\u25C0 Back", @selector(regress:));
    item.rightBarButtonItem = BARBUTTON(@"Forward \u25B6", @selector(progress:));

    // 建立、加入客製導覽列
    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    bar.tintColor = COOKBOOK_PURPLE_COLOR;
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bar.items = [NSArray arrayWithObject:item];
    [self.view addSubview:bar];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [backsplash setupReflection];
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