/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

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
}
@end

@implementation TestBedViewController

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// 取出各方向的加速度數值
	float xx = -acceleration.x;
	float yy = acceleration.y;
	
	// 儲存最近的角位移
    mostRecentAngle = atan2(yy, xx);
	
	// 方向改變了嗎？
	float accelDirX = SIGN(xvelocity) * -1.0f; 
	float newDirX = SIGN(xx);
	float accelDirY = SIGN(yvelocity) * -1.0f;
	float newDirY = SIGN(yy);
	
	// 加速。減低遲滯係數的話，移動速度就會減慢
	if (accelDirX == newDirX) xaccel = (abs(xaccel) + 0.85f) * SIGN(xaccel);
	if (accelDirY == newDirY) yaccel = (abs(yaccel) + 0.85f) * SIGN(yaccel);
	
	// 將加速度套用到目前的速度上
	xvelocity = -xaccel * xx;
	yvelocity = -yaccel * yy;
}

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

    // 加入產生火花的粒子發射器
    float multiplier = 0.25f;

    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = RECTCENTER(butterfly.bounds);
    emitter.emitterMode = kCAEmitterLayerOutline;
    emitter.emitterShape = kCAEmitterLayerCircle;
    emitter.renderMode = kCAEmitterLayerAdditive;
    emitter.emitterSize = CGSizeMake(100 * multiplier, 0);
    
    // 建立發射器單元
    CAEmitterCell* particle = [CAEmitterCell emitterCell];
    particle.emissionLongitude = M_PI;
    particle.birthRate = multiplier * 100.0;
    particle.lifetime = multiplier;
    particle.lifetimeRange = multiplier * 0.35;
    particle.velocity = 180;
    particle.velocityRange = 130;
    particle.emissionRange = 1.1;
    particle.scaleSpeed = 1.0;
    particle.color = [[[UIColor orangeColor] colorWithAlphaComponent:0.1f] CGColor];
    particle.contents = (__bridge id)([UIImage imageNamed:@"spark.png"].CGImage);
    particle.name = @"particle";
    
    emitter.emitterCells = [NSArray arrayWithObject:particle];
    [butterfly.layer addSublayer:emitter];

	// 啟用加速度感應器
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	// 啟動物理計時器
    [NSTimer scheduledTimerWithTimeInterval: 0.03f target: self selector: @selector(tick) userInfo: nil repeats: YES];
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