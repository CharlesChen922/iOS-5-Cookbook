/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TwitPicOperation.h"
#import "XMLParser.h"
#import "TreeNode.h"
#import "UIColor-Random.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define HOST    @"twitpic.com"

@interface PasswordController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
}
- (IBAction) done:(id)sender;
- (IBAction) cancel:(id)sender;
@end

@implementation PasswordController
- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil 
     authenticationMethod:nil];
        
    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
    if (credential)
    {
        username.text = credential.user;
        password.text = credential.password;
    }
}

- (void) storeCredentials
{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username.text password:password.text persistence: NSURLCredentialPersistencePermanent];
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    
    // 最後最新的，設為預設值
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:protectionSpace];
}

- (IBAction) done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self storeCredentials];
}

- (IBAction) cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

// 使用者點擊Done按鈕，表示完成了
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self done:nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // 若開始編輯使用者名稱，清除密碼欄位
    if (textField == username)
        password.text = @"";
    
	// 編輯時，才啟用Cancel按鈕
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

// 在使用者編輯時，檢查該使用者名稱是否已經存在鑰匙圈裡
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != username) return YES;
    
    // 算出最終字串
    NSString *targetString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (!targetString) return YES;
    if (!targetString.length) return YES;
    
    // 檢查是否有可配對成功的密碼資料
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    NSDictionary *credentialDictionary = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
    NSURLCredential *pwCredential = [credentialDictionary objectForKey:targetString];
    if (!pwCredential) return YES;
    
    // 配對成功！更新密碼欄位
    password.text = pwCredential.password;
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
#pragma mark -

#pragma mark Tests
- (void) action: (id) sender
{
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    if (IS_IPAD)
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentModalViewController:nav animated:YES];
}

- (void) doneTweeting: (NSString *) message
{
    UITextView *textView = (UITextView *) self.view;
    
    if ([message hasPrefix:@"ERROR"])
    {
        NSLog(@"%@", message);
        textView.text = message;
        return;
    }

    // 取回訊息資料
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    TreeNode *node = [[XMLParser sharedInstance] parseXMLFromData:data];
    NSString *urlPath = [node leafForKey:@"mediaurl"];
    if (!urlPath)
    {
        textView.text = [@"Did not receive valid URL from TwitPic.\n" stringByAppendingString:[node dump]];
        return;
    }

    textView.text = urlPath;
}

- (void) createWithColor: (UIColor *) aColor
{
    CGRect rect = (CGRect){.size = CGSizeMake(320.0f, 320.0f)};
    UIGraphicsBeginImageContext(rect.size);
    [[UIColor whiteColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    [aColor set];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 40.0f, 40.0f) cornerRadius:32.0f] fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/out.jpg"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [UIImageJPEGRepresentation(image, 0.75f) writeToURL:url atomically:YES];
}

- (void) send: (id) sender
{
    [self createWithColor:[UIColor randomColor]];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/out.jpg"];
    TwitPicOperation *op = [TwitPicOperation operationWithDelegate:self andPath:path];
    [op start];    
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 24.0f : 14.0f];
    textView.editable = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
    self.view = textView;

    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Settings", @selector(action:));
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Send", @selector(send:));
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
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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