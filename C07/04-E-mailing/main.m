/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/UTType.h>

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

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate>
{
    UIImageView *imageView;
    UIPopoverController *popoverController;
    UIImagePickerController *imagePickerController;
    UISwitch *editSwitch;
}
@end

@implementation TestBedViewController

- (NSString *) mimeTypeForExtension: (NSString *) ext 
{
    // 以檔案的副檔名查詢UTI
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) ext, NULL);
    if (!UTI) return nil;
    
    // 以UTI查詢MIME類型，
    // 若無法辨識，會回傳nil
    NSString *mimeType = (__bridge_transfer NSString *) UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);

    return mimeType;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    // 使用者操作結束，解除郵件撰寫控制器
    [self dismissModalViewControllerAnimated:YES];
    
    if (imagePickerController) 
        imagePickerController = nil;
}

- (void) emailImage: (UIImage *) image
{
    if (![MFMailComposeViewController canSendMail])
    {
        if (IS_IPHONE)
        {
            [self dismissModalViewControllerAnimated:YES];
            imagePickerController = nil;
        }
        return;
    }
    
    
    // 設定email
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    [mcvc setSubject:@"Here’s a great photo!"];
    NSString *body = @"<h1>Check this out</h1>\
        <p>I selected this image from the\
        <code><b>UIImagePickerController</b></code>.</p>";
    [mcvc setMessageBody:body isHTML:YES];
    [mcvc addAttachmentData:UIImageJPEGRepresentation(image, 1.0f)
                   mimeType:@"image/jpeg" fileName:@"pickerimage.jpg"];
    
    // 呈現郵件撰寫控制器
    if (IS_IPHONE)
        [imagePickerController presentModalViewController:mcvc animated:YES];
    else
    {
        [popoverController dismissPopoverAnimated:NO];
        mcvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        mcvc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:mcvc animated:YES];
    }
}


// 更新圖像。若是iPhone就解除控制器
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) 
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    imageView.image = image;
    
    [self emailImage:image];
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
        if (popoverController) [popoverController dismissPopoverAnimated:NO];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        popoverController.delegate = self;
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