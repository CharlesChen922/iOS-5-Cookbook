//
//  main.m
//  Hello World
//
//  Created by Erica Sadun on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// 好用的列按鈕項目建立巨集
#define BARBUTTON(TITLE, SELECTOR)     [[UIBarButtonItem alloc] \
initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self \
action:SELECTOR]

@interface HelloWorldController : UIViewController 
{
    UITextField *field1; // Fahrenheit華氏
    UITextField *field2; // Celsius攝氏
}
-(void) convert: (id)sender;
@end

@implementation HelloWorldController

// 轉換成攝氏
- (void) convert: (id) sender
{
    float invalue = [[field1 text] floatValue];
    float outvalue = (invalue - 32.0f) * 5.0f / 9.0f;
    [field2 setText:[NSString stringWithFormat:@"%3.2f", outvalue]];
    [field1 resignFirstResponder];
}

- (void)loadView
{
	// 建立視圖
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 建立兩個文字輸入欄位與兩個標籤
    field1 = [[UITextField alloc] initWithFrame:
              CGRectMake(185.0, 16.0, 97.0, 31.0)];
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.keyboardType = UIKeyboardTypeDecimalPad;
    field1.clearButtonMode = UITextFieldViewModeAlways;
    
    field2 = [[UITextField alloc] initWithFrame:
              CGRectMake(185.0, 72.0, 97.0, 31.0)];
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.enabled = NO;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:
                       CGRectMake(95.0, 19.0, 82.0, 21.0)];
    label1.text = @"Fahrenheit";
    label1.textAlignment = UITextAlignmentLeft;
    label1.backgroundColor = [UIColor clearColor];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:
                       CGRectMake(121.0, 77.0, 56.0, 21.0)];
    label2.text = @"Celsius";
    label2.textAlignment = UITextAlignmentLeft;
    label2.backgroundColor = [UIColor clearColor];
    
    // 將各元件加入內容視圖裡
    [self.view addSubview:field1];
    [self.view addSubview:field2];
    [self.view addSubview:label1];
    [self.view addSubview:label2];
    
    // 設定標題文字，加入Convert按鈕
    self.title = @"Converter";
    self.navigationItem.rightBarButtonItem = 
        BARBUTTON(@"Convert", @selector(convert:));
}

// 應用程式支援所有裝置擺設方向
- (BOOL) shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
}
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *nav = [[UINavigationController alloc]
     initWithRootViewController:[[HelloWorldController alloc] init]];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
    @autoreleasepool {
        UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
    }
}
