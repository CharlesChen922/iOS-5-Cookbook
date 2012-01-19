/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "ActivityAlert.h"

static UIAlertView *alertView = nil;
static UIActivityIndicatorView *activity = nil;

@implementation ActivityAlert
+ (void) presentWithText: (NSString *) alertText
{
    if (alertView)
    {
		// 若警示視圖已存在，更新文字，再次show顯示
        alertView.title = alertText;
        [alertView show];
    }
    else
    {
		// 建立警示視圖，空出一大片空間
        alertView = [[UIAlertView alloc] initWithTitle:alertText message:@"\n\n\n\n\n\n" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alertView show];    
		
		// 建立活動指示器，並啟動旋轉動畫
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.center = CGPointMake(CGRectGetMidX(alertView.bounds), CGRectGetMidY(alertView.bounds));
        [activity startAnimating];
		
		// 加入警示視圖
        [alertView addSubview: activity];
    }
}

// 更新警示視圖的標題文字
+ (void) setTitle: (NSString *) aTitle
{
    alertView.title = aTitle;
}

// 更新警示視圖的訊息，確保插入夠多的空白行
// 請讓訊息簡潔有力
+ (void) setMessage: (NSString *) aMessage;
{
    NSString *message = aMessage;
    while ([message componentsSeparatedByString:@"\n"].count < 7)
        message = [message stringByAppendingString:@"\n"];
    alertView.message = message;
}

// 解除警示視圖，重置靜態變數
+ (void) dismiss
{
    if (alertView)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];

        [activity removeFromSuperview];
        activity = nil;        
        alertView = nil;
    }
}
@end
