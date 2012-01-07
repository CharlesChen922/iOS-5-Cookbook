/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <QuartzCore/QuartzCore.h>

#import "RotatingSegue.h"
#import "SwitchedImageViewController.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

@implementation RotatingSegue
@synthesize goesForward;
@synthesize delegate;

- (void)perform
{
    UIViewController *source = (UIViewController *) super.sourceViewController;
    UIViewController *dest = (UIViewController *) super.destinationViewController;

    // 根據父視圖寬度的一半，移出去
    UIView *backsplash = source.view.superview;
    float endLoc = (goesForward ? 1.0f : -1.0f) * backsplash.frame.size.width;

    // 移進底圖
    dest.view.frame = backsplash.bounds;
    dest.view.alpha = 0.0f;
    
    // 反轉幾何轉換，給目的地視圖用的
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-endLoc, 0.0f);
    transform = CGAffineTransformScale(transform, 0.1f, 0.1f);
    dest.view.transform = transform;
    
    [UIView animateWithDuration:0.6f animations:^(void)
     {
         // 把目的地視圖放進來
         [backsplash addSubview:dest.view];
         dest.view.alpha = 1.0f;
         dest.view.transform = CGAffineTransformIdentity;
         
         // 移出來源視圖，並隱藏
         CGAffineTransform transform = CGAffineTransformMakeTranslation(endLoc, 0.0f);
         transform = CGAffineTransformScale(transform, 0.1f, 0.1f);
         source.view.alpha = 0.0f;
         source.view.transform = transform;

     } completion: ^(BOOL done)
     {
         // 移除、復原來源視圖
         [source.view removeFromSuperview];
         source.view.alpha = 1.0f;
         source.view.transform = CGAffineTransformIdentity;

         // 更新委派
         if (delegate)
             SAFE_PERFORM_WITH_ARG(delegate, @selector(segueDidComplete), nil);
     }];
}
@end