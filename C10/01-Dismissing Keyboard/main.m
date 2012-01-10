/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UIViewController  <UITextFieldDelegate>
{
    UITextField *tf;
}
@end

@implementation TestBedViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// 抓到使用者按下換行鍵的時間點
    //讓文字輸入欄位放棄第一回應者的狀態
    [textField resignFirstResponder];
    return YES;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
   
	// 手動建立文字輸入欄位
	tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
 	tf.center = CGPointMake(self.view.center.x, 30.0f);
	tf.placeholder = @"Name";
	[self.view addSubview:tf];
	
	// 更新文字輸入欄位，包括以IB定義的，
	// 設定委派、換行鍵種類、其他文字特性。
	// 有一點要事先聲明，這裡僅示範文字輸入欄位的屬性設定，
	// 不處理如何尋找視圖──我已經事先知道
	// 在此處理的子視圖是些什麼東西
	for (UIView *view in self.view.subviews)
	{
		if ([view isKindOfClass:[UITextField class]])
		{
            UITextField *aTextField = (UITextField *)view;
            aTextField.delegate = self;
            aTextField.returnKeyType = UIReturnKeyDone;
            aTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            aTextField.borderStyle = UITextBorderStyleRoundedRect;
            aTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		}
	}

}

- (void) viewDidAppear:(BOOL)animated
{
 	tf.center = CGPointMake(self.view.center.x, 30.0f);
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