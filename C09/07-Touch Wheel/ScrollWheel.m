#import "ScrollWheel.h"

#pragma mark Math
// 相對於給定的原點，回傳點的座標
CGPoint centeredPoint(CGPoint pt, CGPoint origin)
{
	return CGPointMake(pt.x - origin.x, pt.y - origin.y);
}

// 相對於給定的原點，回傳點的角度
float getangle (CGPoint p1, CGPoint c1)
{
	// 三角函數，sin=對邊/斜邊，cos=鄰邊/斜邊，tan=對邊/鄰邊
	CGPoint p = centeredPoint(p1, c1);
	float h = ABS(sqrt(p.x * p.x + p.y * p.y));
	float a = p.x;
	float baseAngle = acos(a/h) * 180.0f / M_PI;
	
	// 大於180
	if (p1.y > c1.y) baseAngle = 360.0f - baseAngle;
	
	return baseAngle;
}

// 給定原點，判斷點是否落在半徑範圍內
BOOL pointInsideRadius(CGPoint p1, float r, CGPoint c1)
{
	CGPoint pt = centeredPoint(p1, c1);
	float xsquared = pt.x * pt.x;
	float ysquared = pt.y * pt.y;
	float h = ABS(sqrt(xsquared + ysquared));
	if (((xsquared + ysquared) / h) < r) return YES;
	return NO;
}

@implementation ScrollWheel
@synthesize value;
@synthesize theta;

#pragma mark Object initialization
// 觸控輪的外觀規劃
- (id) initWithFrame: (CGRect) aFrame
{
	if (self = [super initWithFrame:aFrame])
	{
		// 這個控制項的frame固定為200x200
		self.frame = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f); 
		self.center = CGPointMake(CGRectGetMidX(aFrame), CGRectGetMidY(aFrame));
		
		// 觸控輪的美術圖案
		UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wheel.png"]];
		[self  addSubview:iv];
	}
	
	return self;
}

- (id) init
{
	return [self initWithFrame:CGRectZero];
}

+ (id) scrollWheel
{
	return [[self alloc] init];
}

#pragma mark Touch tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint p = [touch locationInView:self];
	
	// 在視圖自己的座標系統裡的中心點
	CGPoint cp = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
	// self.value = 0.0f; // 拿掉註解的話，每次觸控都是重新開始
	
	// 一開始觸控的位置必須在輪子的灰色區域裡
	if (!pointInsideRadius(p, cp.x, cp)) return NO;
	if (pointInsideRadius(p, 30.0f, cp)) return NO;

	// 設定初始角度
	self.theta = getangle([touch locationInView:self], cp);

	// 發出UIControlEventTouchDown事件
	[self sendActionsForControlEvents:UIControlEventTouchDown];

	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	CGPoint p = [touch locationInView:self];
	
	// 在視圖自己的座標系統裡的中心點
	CGPoint cp = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
	
	// 更新
	if (CGRectContainsPoint(self.frame, p))
        [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchDragOutside];		

	// 離開太遠了，距離在50像素以內
	if (!pointInsideRadius(p, cp.x + 50.0f, cp)) return NO;
	
	float newtheta = getangle([touch locationInView:self], cp);
	float dtheta = newtheta - self.theta;

	// 修正極端的狀況
	int ntimes = 0;
	while ((ABS(dtheta) > 300.0f)  && (ntimes++ < 4))
		if (dtheta > 0.0f) dtheta -= 360.0f; else dtheta += 360.0f;

	// 更新數值
	self.value -= dtheta / 360.0f;
	self.theta = newtheta;

	// 送出數值更新的事件
	[self sendActionsForControlEvents:UIControlEventValueChanged];

	return YES;
}

- (void) endTrackingWithTouch: (UITouch *)touch withEvent: (UIEvent *)event
{
    // 檢查觸控結束時，在範圍內還是外
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}


- (void)cancelTrackingWithEvent: (UIEvent *) event
{
	// 取消
	[self sendActionsForControlEvents:UIControlEventTouchCancel];
}
@end
