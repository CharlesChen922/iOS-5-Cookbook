/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "DragView.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
	UIPopoverController *popoverController;
}
@end

@implementation TestBedViewController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// 選定圖檔後，加入新DragView，更新畫面
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	DragView *dv = [[DragView alloc] initWithImage:image];
	dv.center = self.view.center;
	[self.view addSubview:dv];
	
	if (IS_IPHONE)
		[self dismissModalViewControllerAnimated:YES];
	else 
	{
		// iPad，解除懸浮元件控制器
		[popoverController dismissPopoverAnimated:YES];
		popoverController = nil;
	}
}

// 解除挑選器
- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
}

// 懸浮元件已被解除
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
    popoverController = nil;
}

- (void) pickImage: (id) sender
{
	// 建立並初始化挑選器，保持保留計數為1
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	{
		ipc.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		ipc.delegate = self;
	}
	
	if (IS_IPHONE)
	{
		[self presentModalViewController:ipc animated:YES];	
	}
	else 
	{
		// 建立懸浮元件
		popoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
		popoverController.delegate = self;
		[popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Add Image", @selector(pickImage:));
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
    UINavigationController *nav;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
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