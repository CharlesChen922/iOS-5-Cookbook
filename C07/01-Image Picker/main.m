/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define RESIZABLE(_VIEW_)   [_VIEW_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth]
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
    UIImageView *imageView;
    UIPopoverController *popoverController;
    UIImagePickerController *imagePickerController;
    UISwitch *editSwitch;
}
@end

@implementation TestBedViewController

// 更新圖像，若是iPhone就解除控制器
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 如果有就取回編修後的圖像，要不然就取回原先的
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) 
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    imageView.image = image;
    
	if (IS_IPHONE)
	{
        [self dismissModalViewControllerAnimated:YES];
        imagePickerController = nil;
	}
}

// 解除挑選器
- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
    imagePickerController = nil;
}

// 在iPad上，懸浮元件已經解除了
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
	imagePickerController = nil;
    popoverController = nil;
}

- (void) pickImage: (id) sender
{
	// 建立並初始化挑選器
	imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = editSwitch.isOn;
	imagePickerController.delegate = self;
	
	if (IS_IPHONE)
	{   
        [self presentModalViewController:imagePickerController animated:YES];	
	}
	else 
	{
        // 清除任何先前的懸浮元件
        if (popoverController) [popoverController dismissPopoverAnimated:NO];
		
        // 建立新懸浮元件並保留
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        popoverController.delegate = self;
		
		// 顯示懸浮元件
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    RESIZABLE(self.view);
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    RESIZABLE(imageView);
    [self.view addSubview:imageView];

    // 是否允許編輯
    editSwitch = [[UISwitch alloc] init];
    self.navigationItem.titleView = editSwitch;
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickImage:));
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.frame = self.view.bounds;
    imageView.center = CGRectGetCenter(self.view.bounds);
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