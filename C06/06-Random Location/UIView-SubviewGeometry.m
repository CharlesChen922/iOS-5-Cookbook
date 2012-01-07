/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIView-SubviewGeometry.h"
static BOOL seeded = NO;

// 這是個私用函式，出現在我的UIView Frame類目
// 我抄過來放在這裡，就不用匯入其他檔案
CGRect rectWithCenter(CGRect rect, CGPoint center)
{
	CGRect newrect = CGRectZero;
	newrect.origin.x = center.x-CGRectGetMidX(rect);
	newrect.origin.y = center.y-CGRectGetMidY(rect);
	newrect.size = rect.size;
	return newrect;
}

@implementation UIView (SubviewGeometry)
#pragma mark Bounded Placement
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInsets: (UIEdgeInsets) insets
{
	CGRect container = UIEdgeInsetsInsetRect(aView.bounds, insets);
	return CGRectContainsRect(container, rectWithCenter(self.frame, aCenter));
}

- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInset: (float) inset
{
	UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
	return [self canMoveToCenter:aCenter inView:aView withInsets:insets];
}

- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView
{
	return [self canMoveToCenter:aCenter inView:aView withInset:0];
}

#pragma mark Percent Displacement
// 以百分比例指定位置，移動視圖
- (CGPoint) centerInView: (UIView *) aView withHorizontalPercent: (float) h withVerticalPercent: (float) v
{
	// 以insets縮窄視圖的UIEdgeInset，再以子視圖的大小縮窄
	CGRect baseRect = aView.bounds;
	CGRect subRect = CGRectInset(baseRect, self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
	
	// 回傳點座標，水平方向為h%，垂直方向為v%
	float px = (float)(h * subRect.size.width);
	float py = (float)(v * subRect.size.height);
	return CGPointMake(px + subRect.origin.x, py + subRect.origin.y);
}

- (CGPoint) centerInSuperviewWithHorizontalPercent: (float) h withVerticalPercent: (float) v
{
	return [self centerInView:self.superview withHorizontalPercent:h withVerticalPercent:v];
}

#pragma mark Random
// 感謝August Joki與manitoba98
- (CGPoint) randomCenterInView: (UIView *) aView withInsets: (UIEdgeInsets) insets
{
    // 以目前時間當亂數種子
    if (!seeded) {seeded = YES; srandom(time(NULL));}
    
	// 以insets縮窄視圖的UIEdgeInset，再以子視圖的大小縮窄
	CGRect innerRect = UIEdgeInsetsInsetRect([aView bounds], insets);
	CGRect subRect = CGRectInset(innerRect, self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
	
	// 亂數回傳一個點座標
	float rx = (float)(random() % (int)floor(subRect.size.width));
	float ry = (float)(random() % (int)floor(subRect.size.height));
	return CGPointMake(rx + subRect.origin.x, ry + subRect.origin.y);
}

- (CGPoint) randomCenterInView: (UIView *) aView withInset: (float) inset
{
	UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
	return [self randomCenterInView:aView withInsets:insets];
}

- (void) moveToRandomLocationInView: (UIView *) aView animated: (BOOL) animated
{
	if (!animated)
	{
		self.center = [self randomCenterInView:aView withInset:5];
		return;
	}
	
    [UIView animateWithDuration:0.3f animations:^(void){
         self.center = [self randomCenterInView:aView withInset:5];}];
}

- (void) moveToRandomLocationInSuperviewAnimated: (BOOL) animated
{
	[self moveToRandomLocationInView:self.superview animated:animated];
}

@end

