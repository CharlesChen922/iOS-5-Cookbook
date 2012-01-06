/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface NumberViewController : UIViewController
@property (nonatomic, assign) int number;
@property (nonatomic, strong, readonly) UITextView *textView;
+ (id) controllerWithNumber: (int) number;
@end

@implementation NumberViewController
@synthesize number, textView;

// 根據層級深度回傳新的視圖控制器
+ (id) controllerWithNumber: (int) number
{
    NumberViewController *viewController = [[NumberViewController alloc] init];
    viewController.number = number;
    viewController.textView.text = [NSString stringWithFormat:@"Level %d", number];
    return viewController;
}

// 層級深度加一，堆入控制器到堆疊裡
- (void) pushController: (id) sender
{
    NumberViewController *nvc = [NumberViewController controllerWithNumber:number + 1];
    [self.navigationController pushViewController:nvc animated:YES];
}

// 顯示視圖時，設定文字與標題
- (void) viewDidAppear: (BOOL) animated
{
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // 將文字視圖的內容跟標題設定為一樣的文字
    self.title = self.textView.text; 
    self.textView.frame = self.view.frame;
    
    // 加入右邊的列按鈕，負責推入新視圖
    if (number < 6)
        self.navigationItem.rightBarButtonItem = 
        BARBUTTON(@"Push", @selector(pushController:));
}

// 初始化時就建立文字視圖，而不是在載入視圖時
- (id) init
{
    if (!(self = [super init])) return self;
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.frame = [[UIScreen mainScreen] bounds];
    textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 192.0f : 96.0f];
    textView.textAlignment = UITextAlignmentCenter;
    textView.editable = NO;
    textView.autoresizingMask = self.view.autoresizingMask;

    return self;
}

- (void) dealloc
{
    [textView removeFromSuperview];
    textView = nil;
}

- (void) loadView
{
    [super loadView];
    [self.view addSubview:textView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
    NumberViewController *nvc;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	nvc = [NumberViewController controllerWithNumber:1];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:nvc];
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