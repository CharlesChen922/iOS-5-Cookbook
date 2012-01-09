//
//  ColorController.m
//  HelloWorld
//
//  Created by Erica Sadun on 4/30/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import "ColorControl.h"


@implementation ColorControl
@synthesize value; // value是個顏色

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
	
	value = nil;
	self.backgroundColor = [UIColor grayColor];
	
    return self;
}

- (void) updateColorFromTouch: (UITouch *) touch
{
	// 計算色調hue與飽和度saturation
	CGPoint touchPoint = [touch locationInView:self];
	float hue = touchPoint.x / self.frame.size.width;
	float saturation = touchPoint.y / self.frame.size.height;
	
	// 更新色彩值，更新背景顏色
	self.value = [UIColor colorWithHue:hue saturation:saturation brightness:1.0f alpha:1.0f];
	self.backgroundColor = self.value;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

// 持續追蹤控制項範圍內的觸控手指
- (BOOL) continueTrackingWithTouch: (UITouch *) touch withEvent: (UIEvent *) event
{
	// 檢查拖拉的位置在裡面還是在外面
	CGPoint touchPoint = [touch locationInView:self];
	if (CGRectContainsPoint(self.bounds, touchPoint))
		[self sendActionsForControlEvents:UIControlEventTouchDragInside];
	else 
		[self sendActionsForControlEvents:UIControlEventTouchDragOutside];
	
	// 更新色彩值
	[self updateColorFromTouch:touch];

	return YES;
}

// 開始追蹤控制項範圍內的觸控手指
- (BOOL) beginTrackingWithTouch: (UITouch *) touch withEvent: (UIEvent *) event
{
	// 按下手指
	[self sendActionsForControlEvents:UIControlEventTouchDown];
	
	// 更新顏色值
	[self updateColorFromTouch:touch];
	
	return YES;
}

// 觸控追蹤結束
- (void) endTrackingWithTouch: (UITouch *)touch withEvent: (UIEvent *)event
{
	// 檢查結束時的位置在範圍裡面還是外面
	CGPoint touchPoint = [touch locationInView:self];
	if (CGRectContainsPoint(self.bounds, touchPoint))
		[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	else 
		[self sendActionsForControlEvents:UIControlEventTouchUpOutside];
	
	// 更新顏色值
	[self updateColorFromTouch:touch];
}


// 取消觸控事件
- (void)cancelTrackingWithEvent: (UIEvent *) event
{
	[self sendActionsForControlEvents:UIControlEventTouchCancel];
}


- (void)dealloc 
{
	self.value = nil;
}
@end
