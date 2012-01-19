/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

@interface ModalController : UIViewController 
- (IBAction)done:(id)sender;
@end
@implementation ModalController
- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

@interface TestBedViewController : UIViewController <UIPopoverControllerDelegate>
{
    UIPopoverController *popover;
}
@end

@implementation TestBedViewController
- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // 不再抓著懸浮元件
    popover = nil;
}

- (void) action: (id) sender
{
    // 檢查懸浮元件是否已經存在
    if (popover) 
        [popover dismissPopoverAnimated:YES];
    
    // 從storyboard取回導覽控制器
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
    UINavigationController *controller = [storyboard instantiateInitialViewController];
    
    // 模態顯示，或是懸浮元件
    if (IS_IPHONE)
    {
        [self.navigationController presentModalViewController:controller animated:YES];
    }
    else
    {
        // 在iPad上，不使用Done按鈕
        controller.topViewController.navigationItem.rightBarButtonItem = nil;
        
        // 將內容大小設定為iPhone的大小
        controller.topViewController.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f - 44.0f);
        
        // 建立並顯示懸浮元件
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];        
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }    
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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