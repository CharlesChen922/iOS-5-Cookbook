/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define MAXFLOWERS 12
#define HALFFLOWER	32.0f
#define RANDOMPOINT	CGPointMake(random() % ((int)(self.view.bounds.size.width - 2 * HALFFLOWER)) + HALFFLOWER, random() % ((int)(self.view.bounds.size.height - 2 * HALFFLOWER)) + HALFFLOWER)

// #define DATAPATH [NSString stringWithFormat:@"%@/Library/flowers.archive", NSHomeDirectory()]
#define DATAPATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"flowers.archive"]

@interface DragView : UIImageView
{
    CGPoint previousLocation;
}
@property (nonatomic, strong) NSString *whichFlower;
@property (nonatomic, strong) UIViewController *viewController;
@end

@implementation DragView
@synthesize whichFlower, viewController;

- (void) encodeWithCoder: (NSCoder *)coder
{
	[coder encodeCGRect:self.frame forKey:@"viewFrame"];
	[coder encodeObject:self.whichFlower forKey:@"flowerType"];
}

- (id) initWithImage:(UIImage *)image
{
	if (self = [super initWithImage:image])
	{
		self.userInteractionEnabled = YES;
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		self.gestureRecognizers = [NSArray arrayWithObject: pan];
	}
	return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    NSString *aFlower = [coder decodeObjectForKey:@"flowerType"];
    UIImage *image = [UIImage imageNamed:aFlower];   
	if (self = [self initWithImage:image])
    	self.frame = [coder decodeCGRectForKey:@"viewFrame"];
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 將被觸摸到的視圖移到最前面
    [self.superview bringSubviewToFront:self];
    
    // 記住原來的位置
    previousLocation = self.center;
}

- (void) setPosition: (CGPoint) position fromPosition: (CGPoint) previousPosition
{
	// 先準備復原動作。尚未可以使用收尾block（completion block）。
	[[self.undoManager prepareWithInvocationTarget:self] setPosition:previousPosition fromPosition:position];
	[self.viewController performSelector:@selector(checkUndoAndUpdateNavBar) withObject:nil afterDelay:0.2f];
	
	// 改變
	[UIView animateWithDuration:0.1f animations:^{self.center = position;}];
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	CGPoint translation = [uigr translationInView:self.superview];
	CGPoint newcenter = CGPointMake(previousLocation.x + translation.x, previousLocation.y + translation.y);
	
	// 將移動範圍限制在父視圖的bounds內
	float halfx = CGRectGetMidX(self.bounds);
	newcenter.x = MAX(halfx, newcenter.x);
	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
	
	float halfy = CGRectGetMidY(self.bounds);
	newcenter.y = MAX(halfy, newcenter.y);
	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
	
	// 設定新位置
	self.center = newcenter;
	
	// 若手勢結束，更新復原堆疊與導覽列
	if (uigr.state == UIGestureRecognizerStateEnded)
	{
		[self setPosition:self.center fromPosition:previousLocation];
		[self.viewController performSelector:@selector(checkUndoAndUpdateNavBar)];
	}
}

- (void) dealloc
{
    self.whichFlower = nil;
}
@end

@interface TestBedViewController : UIViewController
{
    NSUndoManager *undoManager;
}
@end

@implementation TestBedViewController
- (void) archiveInterface
{
	NSArray *flowers = [self.view subviews];
	[NSKeyedArchiver archiveRootObject:flowers toFile:DATAPATH];
}

- (BOOL) unarchiveInterface
{
	NSArray *flowers = [NSKeyedUnarchiver unarchiveObjectWithFile:DATAPATH];
	if (!flowers) return NO;
	
	for (DragView *aView in flowers)
    {
        aView.viewController = self;
		[self.view addSubview:aView];
    }
	
	return YES;
}

- (void) loadFlowers
{
	for (int i = 0; i < MAXFLOWERS; i++)
	{
		NSString *whichFlower = [[NSArray arrayWithObjects:@"blueFlower.png", @"pinkFlower.png", @"orangeFlower.png", nil] objectAtIndex:(random() % 3)];
		DragView *dragger = [[DragView alloc] initWithImage:[UIImage imageNamed:whichFlower]];
		dragger.center = RANDOMPOINT;
		dragger.userInteractionEnabled = YES;
		dragger.whichFlower = whichFlower;
        dragger.viewController = self;
		[self.view addSubview:dragger];
	}
}

- (void) restart
{
	for (UIView *view in [self.view subviews])
		[view removeFromSuperview];
	
	[self loadFlowers];
}

- (void) checkUndoAndUpdateNavBar
{
    // 不要打斷任何正在進行中的操作 -- 沒有收尾處理方法（completion handlers）
	if ([undoManager isUndoing])
	{
		[self performSelector:@selector(checkUndoAndUpdateNavBar) withObject:nil afterDelay:0.1f];
		return;
	}
	
	// 如果復原堆疊是空的，不顯示Undo按鈕
	if (!undoManager.canUndo) 
		self.navigationItem.leftBarButtonItem = nil;
	else
		self.navigationItem.leftBarButtonItem = BARBUTTON(@"Undo", @selector(undo));
}

- (void) undo
{
	// 復原
	[undoManager undo];
}

- (void) viewDidAppear:(BOOL)animated
{
    undoManager = self.view.window.undoManager;
    [undoManager setLevelsOfUndo:999];
}

- (void) loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Restart", @selector(restart));
	srandom(time(0));
    
	if (![self unarchiveInterface])	
		[self loadFlowers];
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
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate
- (void)applicationWillResignActive:(UIApplication *)application
{

	[tbvc archiveInterface];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
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