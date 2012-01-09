//
//  PullView.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "PullView.h"


#pragma mark Pull-out-an-Image View for use in scroll view

#define DX(p1, p2)	(p2.x - p1.x)
#define DY(p1, p2)	(p2.y - p1.y)

#define SWIPE_DRAG_MIN 16
#define DRAGLIMIT_MAX 12 

// 對掃過手勢進行分類
typedef enum {
	TouchUnknown,
	TouchSwipeLeft,
	TouchSwipeRight,
	TouchSwipeUp,
	TouchSwipeDown,
} SwipeTypes;

@implementation PullView
// 以嵌入式拖曳手勢辨識器建立新視圖
- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
	{
		self.userInteractionEnabled = YES;
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
		self.gestureRecognizers = [NSArray arrayWithObjects: pan, nil];
	}
	return self;
}

// 允許同時進行辨識
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

// 偵測到掃過手勢時，處理拖曳手勢
- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	// 只需對UIScrollView的子類別處理
	if (![self.superview isKindOfClass:[UIScrollView class]]) return;
    
	// 抓出父類別
	UIView *supersuper = self.superview.superview;
	UIScrollView *scrollView = (UIScrollView *) self.superview;
	
	// 計算觸控的位置
	CGPoint touchLocation = [uigr locationInView:supersuper];
	
	// 根據辨識器的狀態，處理觸控事件
	if (uigr.state == UIGestureRecognizerStateBegan) 
	{
		// 初始化控制器
		gestureWasHandled = NO;
		pointCount = 1;
		startPoint = touchLocation;
	}
	
    if (uigr.state == UIGestureRecognizerStateChanged) 
    {
        pointCount++;
        
        // 計算是不是已經發生掃過手勢
        float dx = DX(touchLocation, startPoint);
        float dy = DY(touchLocation, startPoint);
        
        // 偵測已知的掃過類型
        BOOL finished = YES;
        if ((dx > SWIPE_DRAG_MIN) && (ABS(dy) < DRAGLIMIT_MAX)) // hswipe left
            touchtype = TouchSwipeLeft;
        else if ((-dx > SWIPE_DRAG_MIN) && (ABS(dy) < DRAGLIMIT_MAX)) // hswipe right
            touchtype = TouchSwipeRight;
        else if ((dy > SWIPE_DRAG_MIN) && (ABS(dx) < DRAGLIMIT_MAX)) // vswipe up
            touchtype = TouchSwipeUp;
        else if ((-dy > SWIPE_DRAG_MIN) && (ABS(dx) < DRAGLIMIT_MAX)) // vswipe down
            touchtype = TouchSwipeDown;
        else
            finished = NO;
        
        // 如果尚未處理，而且是個往下的掃過手勢，建立新的可拖拉視圖
        if (!gestureWasHandled && finished && (touchtype == TouchSwipeDown))
        {
            dv = [[DragView alloc] initWithImage:self.image];
            dv.center = touchLocation;
            dv.backgroundColor = [UIColor clearColor];
            [supersuper addSubview:dv];			
            scrollView.scrollEnabled = NO;
            gestureWasHandled = YES;
        }
        else if (gestureWasHandled)
        {
            // 偵測後，還能繼續拖拉
            dv.center = touchLocation;
        }
    }
    
    if (uigr.state == UIGestureRecognizerStateEnded)
    {
        // 確定捲動視圖回到可捲動的狀態
        if (gestureWasHandled)
            scrollView.scrollEnabled = YES;
    }
}
@end 



