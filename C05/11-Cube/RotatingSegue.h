/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

// 雙向的串場（segue），可以往兩個方向移動
// 非正式委派方法，送出segueDidComplete訊息

@interface RotatingSegue : UIStoryboardSegue
{
    CALayer *transformationLayer;
    UIView __weak *hostView;
}
@property (assign) BOOL goesForward;
@property (assign) UIViewController *delegate;
@end
