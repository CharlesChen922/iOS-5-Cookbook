/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Geometry.h"
#import "Thumb.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UIViewController
{
    UISlider *slider;
    float previousValue;
}
@end

@implementation TestBedViewController

// 視情況更新大姆哥圖像
- (void) updateThumb: (UISlider *) aSlider
{
	// 數值超過一定變動程度以上，這裡是10%，才更新大姆哥
	if ((slider.value < 0.98) && (ABS(slider.value - previousValue) < 0.1f)) return;
	
	// 高亮度狀態下，建立客製後的大姆哥圖像
    UIImage *customimg = thumbWithLevel(slider.value);
	[slider setThumbImage: customimg forState: UIControlStateHighlighted];
	previousValue = slider.value;
}

// 增大滑桿的尺寸，容納尺寸較大的大姆哥
- (void) startDrag: (UISlider *) aSlider
{
	slider.frame = CGRectInset(slider.frame, 0.0f, -30.0f);
}

// 手指離開螢幕，將滑桿尺寸調回原本大小
- (void) endDrag: (UISlider *) aSlider
{
    slider.frame = CGRectInset(slider.frame, 0.0f, 30.0f);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 設定UISlider全域外觀屬性
    [[UISlider appearance] setMinimumTrackTintColor:[UIColor blackColor]];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor grayColor]];
    
    // 滑桿數值的初始值
	previousValue = -99.0f;
	
	// 建立滑桿
	slider = [[UISlider alloc] initWithFrame:(CGRect){.size=CGSizeMake(200.0f, 40.0f)}];
    [slider setThumbImage:simpleThumb() forState:UIControlStateNormal];
	slider.value = 0.0f;
    	
	// 設定觸控事件（開始、移動、結束）的回呼方法
	[slider addTarget:self action:@selector(startDrag:) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:self action:@selector(updateThumb:) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:self action:@selector(endDrag:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
	
	// 滑桿初始設定
	[self.view addSubview:slider];
	[self performSelector:@selector(updateThumb:) withObject:slider afterDelay:0.1f];
    
    // 外觀設定範例 examples
    /*
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    UIBarButtonItem *hello = BARBUTTON(@"Hello", nil);
    UIBarButtonItem *world = BARBUTTON(@"World", nil);
    world.tintColor = [UIColor greenColor];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Hello"];
    navigationItem.leftBarButtonItem = hello;
    navigationItem.rightBarButtonItem = world;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor purpleColor]];    
    
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 44.0f)];
    [self.view addSubview:bar];
    bar.items = [NSArray arrayWithObject:navigationItem]; 
     */
}

- (void) viewDidAppear:(BOOL)animated
{
    slider.center = CGRectGetCenter(self.view.bounds);
}

- (void) viewDidLayoutSubviews
{
    [self viewDidAppear:NO];
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