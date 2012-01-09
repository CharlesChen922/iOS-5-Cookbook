/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "DragView.h"


@implementation DragView
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// 將被觸摸到的視圖移到最前面
	[self.superview bringSubviewToFront:self];

	// 初始化位移偏移值
	tx = self.transform.tx;
	ty = self.transform.ty;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 3)
	{
		// 連續點擊三次，重置
		self.transform = CGAffineTransformIdentity;
		tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
	}
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void) updateTransformWithOffset: (CGPoint) translation
{
	// 建立混合型幾何轉換，包含位移、旋轉、縮放
	self.transform = CGAffineTransformMakeTranslation(translation.x + tx, translation.y + ty);
	self.transform = CGAffineTransformRotate(self.transform, theta);	
	self.transform = CGAffineTransformScale(self.transform, scale, scale);
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	CGPoint translation = [uigr translationInView:self.superview];
	[self updateTransformWithOffset:translation];
}

- (void) handleRotation: (UIRotationGestureRecognizer *) uigr
{
	theta = uigr.rotation;
	[self updateTransformWithOffset:CGPointZero];
}

- (void) handlePinch: (UIPinchGestureRecognizer *) uigr
{
	scale = uigr.scale;
	[self updateTransformWithOffset:CGPointZero];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}


- (id) initWithImage:(UIImage *)image
{
	// 初始並設定為可觸控
	if (!(self = [super initWithImage:image])) return self;
	
	self.userInteractionEnabled = YES;
	
	// 重置為同等幾何轉換
	self.transform = CGAffineTransformIdentity;
	tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;

	// 加入手勢辨識器
	UIRotationGestureRecognizer *rot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	self.gestureRecognizers = [NSArray arrayWithObjects: rot, pinch, pan, nil];
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
	
	return self;
}
@end
