/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

// 回傳某視圖完整的子視圖清單
NSArray *allSubviews(UIView *aView)
{
	NSArray *results = [aView subviews];
	for (UIView *eachView in [aView subviews])
	{
		NSArray *allViews = allSubviews(eachView);
		if (allViews) 
            results = [results arrayByAddingObjectsFromArray:allViews];
	}
	return results;
}

// 回傳應用程式裡所有的視圖
NSArray *allApplicationViews()
{
    NSArray *results = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
	{
		NSArray *allViews = allSubviews(window);
        if (allViews) 
            results = [results arrayByAddingObjectsFromArray: allViews];
	}
    return results;
}

// 回傳含有所有父視圖的陣列，從視窗開始
NSArray *pathToView(UIView *aView)
{
    NSMutableArray *array = [NSMutableArray arrayWithObject:aView];
    UIView *view = aView;
    UIWindow *window = aView.window;
    while (view != window)
    {
        view = [view superview];
        [array insertObject:view atIndex:0];
    }
    return array;
}

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) collectViews: (id) sender
{
    // 主視圖裡兩個子視圖，圖像視圖當底圖，標籤顯示被點選的號碼
	printf("Subviews of the main view:\n");
	NSLog(@"%@", allSubviews(self.view));
	
	printf("Path to each main subview:\n");
	for (UIView *eachView in allSubviews(self.view))
		NSLog(@"%@", pathToView(eachView));
	
	// 視圖數目，比你想的還要多！
	printf("\nAll window subviews:\n");
	NSLog(@"%@", allApplicationViews());
}

-(void) segmentAction: (UISegmentedControl *) sender
{
	// 以分段控制項編號更新標籤
	UILabel *label = (UILabel *)[self.view viewWithTag:101];
	[label setText:[NSString stringWithFormat:@"%0d", sender.selectedSegmentIndex + 1]];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(collectViews:));
    
    // 建立分段控制項，三種風格選一個
	NSArray *buttonNames = [NSArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", @"Five", @"Six", nil];
	UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar; 
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.momentary = YES;
	self.navigationItem.titleView = segmentedControl;	
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