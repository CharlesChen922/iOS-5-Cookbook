/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "Geometry.h"
#import "UIImage-Utilities.h"
#import "Orientation.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define RESIZABLE(_VIEW_)   [_VIEW_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth]
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
    UIImageView *imageView;
	UIImage *baseImage;
	UIPopoverController *popoverController;
	UIImagePickerController *imagePickerController;
    UISegmentedControl *seg;
}
@end

@implementation TestBedViewController

- (void) viewDidAppear:(BOOL)animated
{
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) viewDidLayoutSubviews
{
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) adjustImage
{
	if(baseImage){
		CGSize destSize = CGSizeMake(300.0f, 300.0f);
		
		if (seg.selectedSegmentIndex == 0) 
			imageView.image = [[baseImage copy] fitInSize:destSize];
		else if (seg.selectedSegmentIndex == 1)
			imageView.image = [[baseImage copy] centerInSize:destSize];
		else
			imageView.image = [[baseImage copy] fillSize:destSize];
	}
}

// 更新圖像，若是iPhone就解除控制器
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 如果有就取回編修後的圖像，要不然就取回原先的
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) 
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	baseImage = [image copy];
	[self adjustImage];
	
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
    imagePickerController.allowsEditing = NO;
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
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
      
    imageView = [[UIImageView alloc] initWithFrame:(CGRect){.size=CGSizeMake(300.0f, 300.0f)}];
    imageView.backgroundColor = [UIColor darkGrayColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    
    NSArray *items = [@"Fit*Center*Fill" componentsSeparatedByString:@"*"];
    seg = [[UISegmentedControl alloc] initWithItems:items];
    seg.selectedSegmentIndex = 0;
	[seg addTarget:self action:@selector(adjustImage) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;

	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickImage:));
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
    //[application setStatusBarHidden:YES];
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