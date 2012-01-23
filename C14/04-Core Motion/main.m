/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

#define RECTCENTER(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define SIGN(x)	((x < 0.0f) ? -1.0f : 1.0f)

@interface TestBedViewController : UIViewController <UIAccelerometerDelegate>
{
    UIImageView *butterfly;

	float xaccel;
	float xvelocity;
    
	float yaccel;
	float yvelocity;
    
    float mostRecentAngle;
    
    CMMotionManager *motionManager;
    NSTimer *timer;
}
@end

@implementation TestBedViewController
- (void) tick
{
	// 改變位置前，重置幾何轉換矩陣
    butterfly.transform = CGAffineTransformIdentity;
    
	// 根據目前速度向量，移動蝴蝶
    CGRect rect = CGRectOffset(butterfly.frame, xvelocity, 0.0f);
    if (CGRectContainsRect(self.view.bounds, rect))
        butterfly.frame = rect;

    rect = CGRectOffset(butterfly.frame, 0.0f, yvelocity);
    if (CGRectContainsRect(self.view.bounds, rect))
        butterfly.frame = rect;
    
	// 旋轉蝴蝶，跟位置無關
    butterfly.transform = CGAffineTransformMakeRotation(mostRecentAngle + M_PI_2);
}

- (void) shutDownMotionManager
{
    NSLog(@"Shutting down motion manager");
    [motionManager stopAccelerometerUpdates];
    motionManager = nil;
    
    [timer invalidate];
    timer = nil;
}

- (void) establishMotionManager
{
    if (motionManager)
        [self shutDownMotionManager];

    NSLog(@"Establishing motion manager");
    
    // 建立運動管理者
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.accelerometerAvailable)
        [motionManager 
         startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] 
         withHandler:^(CMAccelerometerData *data, NSError *error)
         {
             // 取出各方向的加速度數值
             float xx = -data.acceleration.x;
             float yy = data.acceleration.y;
             mostRecentAngle = atan2(yy, xx);
             
             // 方向改變了嗎？
             float accelDirX = SIGN(xvelocity) * -1.0f; 
             float newDirX = SIGN(xx);
             float accelDirY = SIGN(yvelocity) * -1.0f;
             float newDirY = SIGN(yy);
             
             // 加速。減低遲滯係數的值，速度會變慢。
             if (accelDirX == newDirX) xaccel = (abs(xaccel) + 0.85f) * SIGN(xaccel);
             if (accelDirY == newDirY) yaccel = (abs(yaccel) + 0.85f) * SIGN(yaccel);
             
             // 將加速度套用在目前速度向量上
             xvelocity = -xaccel * xx;
             yvelocity = -yaccel * yy;
         }];
    
    
	// 啟動物理計時器
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.03f target: self selector: @selector(tick) userInfo: nil repeats: YES];
}

- (void) initButterfly
{
    CGSize size;
    
	// 載入組成動畫的圖檔
	NSMutableArray *butterflies = [NSMutableArray array];
	for (int i = 1; i <= 17; i++) 
    {
        NSString *fileName = [NSString stringWithFormat:@"bf_%d.png", i];
        UIImage *image = [UIImage imageNamed:fileName];
        size = image.size;
		[butterflies addObject:image];
    }
	
	// 動畫開始
	butterfly = [[UIImageView alloc] initWithFrame:(CGRect){.size=size}];
	[butterfly setAnimationImages:butterflies];
	butterfly.animationDuration = 0.75f;
	[butterfly startAnimating];

	// 設定蝴蝶的初始速度與加速度
	xaccel = 2.0f;
	yaccel = 2.0f;
	xvelocity = 0.0f;
	yvelocity = 0.0f;
	
    // 加入蝴蝶視圖
	butterfly.center = RECTCENTER(self.view.bounds);
	[self.view addSubview:butterfly];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initButterfly];
}

@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate
- (void) applicationWillResignActive:(UIApplication *)application
{
    [tbvc shutDownMotionManager];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    [tbvc establishMotionManager];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
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