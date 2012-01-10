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

@interface KeyInputToolbar: UIToolbar <UIKeyInput>
{
	NSMutableString *string;
}
@end

@implementation KeyInputToolbar

// 有文字可以被刪除嗎？
- (BOOL) hasText
{
	if (!string || !string.length) return NO;
	return YES;
}

// 列按鈕被點擊時，變成第一回應者
- (void) resume
{
    [self becomeFirstResponder];
}

// 重新載入工具列，更新字串
- (void) update
{
	NSMutableArray *theItems = [NSMutableArray array];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[theItems addObject:BARBUTTON(string, @selector(resume))];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	self.items = theItems;	
}

// 插入新字串
- (void)insertText:(NSString *)text
{
	if (!string) string = [NSMutableString string];
	[string appendString:text];
	[self update];
}

// 刪除一個字元
- (void)deleteBackward
{
	// 請特別小心，即使hasText回傳YES
	if (!string) 
	{
		string = [NSMutableString string];
		return;
	}
	
	if (!string.length) 
		return;
	
	// 刪除一個字元
	[string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
	[self update];
}

// 允許視圖變成第一回應者
- (BOOL)canBecomeFirstResponder 
{ 
	return YES; 
}

// 各位，提交給App Store的應用軟體裡，不要使用底下的程式碼。
// 強迫啟動硬體鍵盤的處理流程
/* - (void) disableOnscreenKeyboard
 {
 void *gs = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY);
 int (*kb)(BOOL yorn) = (int (*)(BOOL))dlsym(gs, "GSEventSetHardwareKeyboardAttached");
 kb(YES);
 dlclose(gs);	
 } */


// 被觸控時，變成第一回應者
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	// [self disableOnscreenKeyboard]; // 可能會被App Store退回
	[self becomeFirstResponder];
}	
@end

@interface TestBedViewController : UIViewController
{
    KeyInputToolbar *kit;
}
@end

@implementation TestBedViewController

- (void) done: (id) sender
{
    [kit resignFirstResponder];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(done:));
    
	kit = [[KeyInputToolbar alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.view.frame.size.width, 44.0f)];
	kit.userInteractionEnabled = YES;
	kit.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:kit];
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
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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