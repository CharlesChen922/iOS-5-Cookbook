/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ModalAlertDelegate.h"

@implementation ModalAlertDelegate

- (id)initWithAlert: (UIAlertView *) anAlert
{
    if (!(self = [super init])) return self;    
    alertView = anAlert;
    return self;
}

-(void)alertView:(UIAlertView*)aView clickedButtonAtIndex:(NSInteger)anIndex 
{
	// 儲存被點擊的按鈕索引值
    index = anIndex;
	
	// 警示視圖使用完畢
    alertView = nil;
	
	// 停止run loop，取回控制權
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (int) show
{
	// 作為警示視圖的委派物件，進行顯示
    [alertView setDelegate:self];
    [alertView show];
    
	// 等待，直到使用者結束操作動作
    CFRunLoopRun();

    return index;
}

+ (id) delegateWithAlert: (UIAlertView *) anAlert
{
    ModalAlertDelegate *mad = [[self alloc] initWithAlert:anAlert];
    return mad;
}
@end
