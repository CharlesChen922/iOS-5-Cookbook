//
//  DragView.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "DragView.h"

@implementation DragView
- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
	{
		self.userInteractionEnabled = YES;
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		self.gestureRecognizers = [NSArray arrayWithObject: pan];
	}
	return self;
}

// 將被觸控的視圖移到最上面
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.superview bringSubviewToFront:self];
	previousLocation = self.center;
}

// 移動視圖
- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	CGPoint translation = [uigr translationInView:self.superview];
	self.center = CGPointMake(previousLocation.x + translation.x, previousLocation.y + translation.y);
	
}
@end
