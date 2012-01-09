/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Geometry.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define CAPWIDTH    110.0f
#define INSETS      (UIEdgeInsets){0.0f, CAPWIDTH, 0.0f, CAPWIDTH}
#define BASEGREEN   [[UIImage imageNamed:@"green.png"] resizableImageWithCapInsets:INSETS]
#define ALTGREEN    [[UIImage imageNamed:@"green2.png"] resizableImageWithCapInsets:INSETS]
#define BASERED     [[UIImage imageNamed:@"red.png"] resizableImageWithCapInsets:INSETS]
#define ALTRED      [[UIImage imageNamed:@"red2.png"] resizableImageWithCapInsets:INSETS]

@interface TestBedViewController : UIViewController
{
    UIButton *button;
    UIImageView *imageView;
    BOOL isOn;
}
@end

@implementation TestBedViewController

- (void) toggleButton: (UIButton *) aButton
{
	if ((isOn = !isOn))
	{
		[button setTitle:@"On" forState:UIControlStateNormal];
		[button setTitle:@"On" forState:UIControlStateHighlighted];
		[button setBackgroundImage:BASEGREEN forState:UIControlStateNormal];
		[button setBackgroundImage:ALTGREEN forState:UIControlStateHighlighted];
	}
	else
	{
		[button setTitle:@"Off" forState:UIControlStateNormal];
		[button setTitle:@"Off" forState:UIControlStateHighlighted];
		[button setBackgroundImage:BASERED forState:UIControlStateNormal];
		[button setBackgroundImage:ALTRED forState:UIControlStateHighlighted];
	}
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    // 根據美術圖案的大小建立按鈕
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0.0f, 0.0f, 300.0f, 233.0f);
	
	// 設定按鈕的對齊屬性
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	// 設定字型與顏色
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
	
	// 加入動作
	[button addTarget:self action:@selector(toggleButton:) forControlEvents: UIControlEventTouchUpInside];
    
    // 載入蝴蝶
	NSMutableArray *butterflies = [NSMutableArray array];
	UIImage *image;
	for (int i = 1; i <= 17; i++) {
		NSString *butterfly = [NSString stringWithFormat:@"bf_%d.png", i];
		if ((image = [UIImage imageNamed:butterfly])) 
            [butterflies addObject:image];
	}
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
	[imageView setAnimationImages:butterflies];
	[imageView setAnimationDuration:1.2f];
	[imageView startAnimating];
    
	// 將按鈕放入視圖裡，並初始化美術圖案
    [self.view addSubview:imageView];
    [self.view addSubview:button];
    [self toggleButton:button];
}

- (void) viewDidAppear:(BOOL)animated
{
    button.center = CGRectGetCenter(self.view.bounds);
    imageView.center = button.center;
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