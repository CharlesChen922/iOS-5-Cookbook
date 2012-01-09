/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define POINTSTRING(_CGPOINT_) (NSStringFromCGPoint(_CGPOINT_))
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

#pragma mark Bezier Utilities
// 從貝茲路徑裡取得點座標
void getPointsFromBezier(void *info, const CGPathElement *element) 
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;    
    
    // 取得路徑元素型別與其上的點
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // 如果可用的話（根據型別），把點加入
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }    
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

NSArray *pointsFromBezierPath(UIBezierPath *bpath)
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(bpath.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}

#pragma mark Geometry Utilities
// 回傳給定矩形的中心點
CGPoint getRectCenter(CGRect rect)
{
	return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

// 根據給定中心點建立矩形
CGRect rectAroundCenter(CGPoint center, float dx, float dy)
{
	return CGRectMake(center.x - dx, center.y - dy, dx * 2, dy * 2);
}

// 兩個向量，正規化後，求出點積
float dotproduct (CGPoint v1, CGPoint v2)
{
	float dot = (v1.x * v2.x) + (v1.y * v2.y);
	float a = ABS(sqrt(v1.x * v1.x + v1.y * v1.y));
	float b = ABS(sqrt(v2.x * v2.x + v2.y * v2.y));
	dot /= (a * b);
	
	return dot;
}

// 回傳兩點的距離
float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

// 根據給定的原點，回傳點座標
CGPoint pointWithOrigin(CGPoint pt, CGPoint origin)
{
	return CGPointMake(pt.x - origin.x, pt.y - origin.y);
}

#pragma mark Circle Detection

// 計算並回傳最小的包圍矩形
CGRect boundingRect(NSArray *points)
{
	CGRect rect = CGRectZero;
	CGRect ptRect;
	
	for (int i = 0; i < points.count; i++)
	{
        CGPoint pt = POINT(i);
		ptRect = CGRectMake(pt.x, pt.y, 0.0f, 0.0f);
		rect = (CGRectEqualToRect(rect, CGRectZero)) ? ptRect : CGRectUnion(rect, ptRect);
	}
	
	return rect;
}

#define DX(p1, p2)	(p2.x - p1.x)
#define DY(p1, p2)	(p2.y - p1.y)
#define SIGN(NUM) (NUM < 0 ? (-1) : 1)
#define DEBUG NO

CGRect testForCircle(NSArray *points, NSDate *firstTouchDate)
{
	if (points.count < 2) 
	{
		if (DEBUG) NSLog(@"Too few points (2) for circle");
		return CGRectZero;
	}
	
	// 檢測1：在多短時間內必須完成手勢
	float duration = [[NSDate date] timeIntervalSinceDate:firstTouchDate];
	if (DEBUG) NSLog(@"Transit duration: %0.2f", duration);
        
        float maxDuration = 2.0f;
        if (duration > maxDuration) // 在模擬器上，允許更長一點的時間
        {
            if (DEBUG) NSLog(@"Excessive touch duration: %0.2f seconds vs %0.1f seconds", duration, maxDuration);
            return CGRectZero;
        }
	
	// 檢測2：方向變化的次數
	// 限制在4次左右
	int inflections = 0;
	for (int i = 2; i < (points.count - 1); i++)
	{
		float dx = DX(POINT(i), POINT(i-1));
		float dy = DY(POINT(i), POINT(i-1));
		float px = DX(POINT(i-1), POINT(i-2));
		float py = DY(POINT(i-1), POINT(i-2));
		
		if ((SIGN(dx) != SIGN(px)) || (SIGN(dy) != SIGN(py)))
			inflections++;
	}
	
	if (inflections > 5)
	{
		if (DEBUG) NSLog(@"Excessive number of inflections (%d vs 4). Fail.", inflections);
		return CGRectZero;
	}
	
	// 檢測3：起點與終點必須在一定程度內靠在一起
	float tolerance = [[[UIApplication sharedApplication] keyWindow] bounds].size.width / 3.0f;	
	if (distance(POINT(0), POINT(points.count - 1)) > tolerance)
	{
		if (DEBUG) NSLog(@"Start and end points too far apart. Fail.");
		return CGRectZero;
	}
	
	// 檢測4：計算手勢劃過的角度
	CGRect circle = boundingRect(points);
	CGPoint center = getRectCenter(circle);
	float distance = ABS(acos(dotproduct(pointWithOrigin(POINT(0), center), pointWithOrigin(POINT(1), center))));
	for (int i = 1; i < (points.count - 1); i++)
		distance += ABS(acos(dotproduct(pointWithOrigin(POINT(i), center), pointWithOrigin(POINT(i+1), center))));
        
        float transitTolerance = distance - 2 * M_PI;
        
        if (transitTolerance < 0.0f) // 小於2*PI
        {
            if (transitTolerance < - (M_PI / 4.0f)) // 45度或更大
            {
                if (DEBUG) NSLog(@"Transit was too short, under 315 degrees");
                return CGRectZero;
            }
        }
	
	if (transitTolerance > M_PI) // 多了180度以上
	{
		if (DEBUG) NSLog(@"Transit was too long, over 540 degrees");
		return CGRectZero;
	}
	
	return circle;
}


@interface TouchTrackerView : UIView
{
    UIBezierPath *path;
    NSDate *firstTouchDate;
}
@end

@implementation TouchTrackerView
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    path = [UIBezierPath bezierPath];    
    path.lineWidth = 4.0f;
    
    UITouch *touch = [touches anyObject];
    [path moveToPoint:[touch locationInView:self]];
    
    firstTouchDate = [NSDate date];
}

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    UITouch *touch = [touches anyObject];
    [path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void) drawRect:(CGRect)rect
{
    [COOKBOOK_PURPLE_COLOR set];
    [path stroke];
    
    CGRect circle = testForCircle(pointsFromBezierPath(path), firstTouchDate);
    if (!CGRectEqualToRect(CGRectZero, circle))
    {
        [[UIColor redColor] set];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circle];
        circlePath.lineWidth = 6.0f;
        [circlePath stroke];
        
        CGRect  centerBit = rectAroundCenter(getRectCenter(circle), 4.0f, 4.0f);
        UIBezierPath *centerPath = [UIBezierPath bezierPathWithOvalInRect:centerBit];
        [centerPath fill];
    }
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        self.multipleTouchEnabled = NO;
    
    return self;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) action: (id) sender
{
}

- (void) loadView
{
    [super loadView];
    self.view = [[TouchTrackerView alloc] initWithFrame:self.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    window.rootViewController = tbvc;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}