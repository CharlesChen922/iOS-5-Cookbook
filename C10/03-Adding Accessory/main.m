/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
	UITextView *tv;
	UIToolbar *tb;
}
@end

@implementation TestBedViewController
CGRect CGRectShrinkHeight(CGRect rect, CGFloat amount)
{
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - amount);
}

- (UIToolbar *) accessoryView
{
	// 回傳輔助視圖，有著兩個按鈕的工具列：清除與完成
	tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	tb.tintColor = [UIColor darkGrayColor];
	
	NSMutableArray *items = [NSMutableArray array];
	[items addObject:BARBUTTON(@"Clear", @selector(clearText))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:BARBUTTON(@"Done", @selector(leaveKeyboardMode))];
	tb.items = items;	
	
	return tb;
}

// 以輔助視圖上的按鈕清除輸入文字
- (void) clearText
{
	[tv setText:@""];
}

// 以輔助視圖上的按鈕解除鍵盤
- (void) leaveKeyboardMode
{
	[tv resignFirstResponder];
}

- (void) keyboardWillHide: (NSNotification *) notification
{
	// 回到先前大小
	tv.frame = self.view.bounds;
}

- (void) adjustForKeyboard: (NSNotification *) notification
{
    
	// 取得userInfo字典裡的鍵盤bounds
	CGRect kbounds;
	NSDictionary *userInfo = [notification userInfo];
	[(NSValue *)[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] getValue:&kbounds];
    
	// 收縮文字視圖的frame -- 註解底下這行，看看預設的樣子
    CGRect destRect = CGRectShrinkHeight(self.view.bounds, kbounds.size.height);
	tv.frame = destRect;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
	// 將客製輔助視圖賦值給文字視圖
    tv = [[UITextView alloc] initWithFrame:self.view.bounds];
	tv.font = [UIFont fontWithName:@"Georgia" size:(IS_IPAD) ? 24.0f : 14.0f];
    tv.inputAccessoryView = [self accessoryView];

	[self.view addSubview:tv];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustForKeyboard:) name:UIKeyboardDidShowNotification object:nil];
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