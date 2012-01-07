/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
}

- (void) animate: (id) sender
{
	// 設定
	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 1.0f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	
	switch ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]) 
	{
		case 0:
			animation.type = kCATransitionFade;
			break;
		case 1:
			animation.type = kCATransitionMoveIn;
			break;
		case 2:
			animation.type = kCATransitionPush;
			break;
		case 3:
			animation.type = kCATransitionReveal;
		default:
			break;
	}
	animation.subtype = kCATransitionFromBottom;
	
	// 執行動畫
	[self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
	[self.view.layer addAnimation:animation forKey:@"animation"];
}

- (void) viewDidAppear: (BOOL) animated
{
	// 建立後面的物件
	UIImageView *backObject = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircle.png"]] autorelease];
	backObject.center = self.view.center;
	[self.view addSubview:backObject];
	
	// 建立前面的物件
	UIImageView *frontObject = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircleMaroon.png"]] autorelease];
	frontObject.center = self.view.center;
	[self.view addSubview:frontObject];
	
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(animate:));
	
	// 加入分段控制項，選擇動畫效果種類
	UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:[@"Fade Over Push Reveal" componentsSeparatedByString:@" "]];
	sc.segmentedControlStyle = UISegmentedControlStyleBar;
	sc. selectedSegmentIndex = 0;
	self.navigationItem.titleView = [sc autorelease];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
	UINavigationController *nav;
}
@end
@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	nav = [[UINavigationController alloc] initWithRootViewController:[[[TestBedViewController alloc] init] autorelease]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
- (void) dealloc
{
	[nav.view removeFromSuperview];	[nav release];	[window release];	[super dealloc];
}
@end
int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}