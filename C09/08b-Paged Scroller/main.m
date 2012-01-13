/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define INITPAGES	3

typedef void (^AnimationBlock)(void);
typedef void (^CompletionBlock)(BOOL completed);

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *sv;
    CGFloat dimension;
    
	IBOutlet UIPageControl *pageControl;
    
}
@end

@implementation TestBedViewController

- (void) pageTurn: (UIPageControl *) aPageControl
{
	// Animate to the new page
	float width = self.view.frame.size.width;
	int whichPage = aPageControl.currentPage;
	[UIView animateWithDuration:0.3f
					 animations:^{sv.contentOffset =
						 CGPointMake(width * whichPage, 0.0f);}];
}

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	// Update the page control to match the current scroll
	CGPoint offset = aScrollView.contentOffset;
	float width = self.view.frame.size.width;
	pageControl.currentPage = offset.x / width;
}
#define NPAGES 3
- (void) loadView
{
	[super loadView];
	float width = self.view.frame.size.width;

	sv = [[UIScrollView alloc] initWithFrame:
		  CGRectMake(0.0f, 0.0f, width, width)];
	sv.contentSize = CGSizeMake(NPAGES * width, sv.frame.size.height);
	sv.pagingEnabled = YES;
	sv.delegate = self;

	for (int i = 0; i < NPAGES; i++)
	{
		NSString *filename =
		    [NSString stringWithFormat:@"BFlyCircle%d.png", i+1];
		UIImageView *iv = [[UIImageView alloc] initWithImage:
						   [UIImage imageNamed:filename]];
		iv.frame = CGRectMake(i * width, 0.0f, width, width);
		[sv addSubview:iv];
	}

	[self.view addSubview:sv];

	pageControl.numberOfPages = 3;
	pageControl.currentPage = 0;
	[pageControl addTarget:self action:@selector(pageTurn:)
		  forControlEvents:UIControlEventValueChanged];
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
    //[application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];

	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] initWithNibName:@"TestBedViewController" bundle:[NSBundle mainBundle]];
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