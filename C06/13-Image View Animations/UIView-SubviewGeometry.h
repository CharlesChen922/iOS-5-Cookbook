/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface UIView (SubviewGeometry)
// 給定中心點座標，檢查視圖是否位於父視圖的範圍內
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInsets: (UIEdgeInsets) insets;
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInset: (float) inset;
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView;

// 以百分比例在父視圖裡移動視圖，譬如50%水平方向、60%垂直方向
// 視圖一定會被侷限在父視圖的範圍內
- (CGPoint) centerInView: (UIView *) aView withHorizontalPercent: (float) h withVerticalPercent: (float) v;
- (CGPoint) centerInSuperviewWithHorizontalPercent: (float) h withVerticalPercent: (float) v;

// 亂數移動到父視圖裡的某一點，子視圖一定位於父視圖範圍內，
// 如果有指定inset，也會位於inset內。
- (CGPoint) randomCenterInView: (UIView *) aView withInsets: (UIEdgeInsets) insets;
- (CGPoint) randomCenterInView: (UIView *) aView withInset: (float) inset;

// 以動畫效果表現視圖的移動，在某一個視圖裡或父視圖裡移動，
// 子視圖一定會在父視圖的範圍裡完整顯示
- (void) moveToRandomLocationInView: (UIView *) aView animated: (BOOL) animated;
- (void) moveToRandomLocationInSuperviewAnimated: (BOOL) animated;
@end
