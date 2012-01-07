/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <math.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

@interface TestBedViewController : UIViewController
{
    NSTimer *timer;
    int theta;
    UIImageView *imageView;
}
@end

@implementation TestBedViewController

- (void) move: (NSTimer *) aTimer
{
	// 每次旋轉1%的PI圓周率
    CGFloat angle = theta * (M_PI / 100.0f);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    
	// theta範圍是0%到199%的圓周率，也就是0到2*PI
	theta = (theta + 1) % 200;
	
    // 為了讓畫面有趣一點，以cosine的絕對值進行縮放
    float degree = cos(angle);
    if (degree < 0.0) degree *= -1.0f;
    degree += 0.5f;
	
	// 縮放與旋轉結合在一起
    CGAffineTransform scaled = CGAffineTransformScale(transform, degree, degree);
	
    // 套用仿射幾何轉換
    if(imageView)
		[imageView setTransform:scaled];
}

- (void) start: (id) sender
{
	timer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(move:) userInfo:nil repeats:YES];
	[self move:nil];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Stop", @selector(stop:));
}

- (void) stop: (id) sender
{
	[timer invalidate];
	timer = nil;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(start:));
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(start:));
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BflyCircle.png"]];
	[self.view addSubview:imageView];
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
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
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