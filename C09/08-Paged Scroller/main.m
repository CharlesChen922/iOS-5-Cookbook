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
    UIScrollView *scrollView;
    CGFloat dimension;
    
	IBOutlet UIPageControl *pageControl;
    
	IBOutlet UIButton *addButton;
	IBOutlet UIButton *cancelButton;
	IBOutlet UIButton *confirmButton;
	IBOutlet UIButton *deleteButton;
}
@end

@implementation TestBedViewController

// 以頁面控制項切換頁面
- (void) pageTurn: (UIPageControl *) aPageControl
{
	int whichPage = aPageControl.currentPage;
	[UIView animateWithDuration:0.3f 
					 animations:^{scrollView.contentOffset = CGPointMake(dimension * whichPage, 0.0f);}];
}

// 以捲動切換頁面。加入一些彈性
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    // 稍微模糊一點，並取floor，捨棄小數點
	pageControl.currentPage = floor((scrollView.contentOffset.x / dimension) + 0.25);
}

// 回傳新顏色
- (UIColor *)randomColor
{
	float red = (64 + (random() % 191)) / 256.0f;
	float green = (64 + (random() % 191)) / 256.0f;
	float blue = (64 + (random() % 191)) / 256.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

// 新增、刪除、擺設方向更改時，重新規劃頁面
- (void) layoutPages
{
    int whichPage = pageControl.currentPage;
    
	// 更新捲動視圖與內容大小
    scrollView.frame = CGRectMake(0.0f, 0.0f, dimension, dimension);
    scrollView.contentSize = CGSizeMake(pageControl.numberOfPages * dimension, dimension);
	scrollView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    // 只顯示這些頁面（標號為999）
    float offset = 0.0f;
    for (UIView *eachView in scrollView.subviews)
    {
        if (eachView.tag == 999)
        {
            eachView.frame = CGRectMake(offset, 0.0f, dimension, dimension);
            offset += dimension;
        }
    }
    
	// 捲動到新頁面
    scrollView.contentOffset = CGPointMake(dimension * whichPage, 0.0f);
}

// 新增頁面
- (void) addPage
{
	pageControl.numberOfPages = pageControl.numberOfPages + 1;
	pageControl.currentPage = pageControl.numberOfPages - 1;
    
	UIView *aView = [[UIView alloc] init];
	aView.backgroundColor = [self randomColor];
    aView.tag = 999;
	[scrollView addSubview:aView];
    
    [self layoutPages];
}

// 使用者要求新增頁面
- (void) requestAdd: (UIButton *) button
{
	[self addPage];
	addButton.enabled = (pageControl.numberOfPages < 8) ? YES : NO;
	deleteButton.enabled = YES;
	[self pageTurn:pageControl];
}

// 刪除目前頁面
- (void) deletePage
{
	int whichPage = pageControl.currentPage;
	pageControl.numberOfPages = pageControl.numberOfPages - 1;
    int i = 0;
    for (UIView *eachView in scrollView.subviews)
    {
        if ((i == whichPage) && (eachView.tag == 999))
        {
            [eachView removeFromSuperview];
            break;
        }
        
        if (eachView.tag == 999) i++;
    }
    
    [self layoutPages];
}

// 取消刪除
- (void) hideConfirmAndCancel
{
	cancelButton.enabled = NO;
	[UIView animateWithDuration:0.3f animations:^(void)
    {
        confirmButton.center = CGPointMake(deleteButton.center.x - 300.0f, deleteButton.center.y);
    }];
}

// 使用者確定刪除目前頁面
- (void) confirmDelete: (UIButton *) button
{
	[self deletePage];
	addButton.enabled = YES;
	deleteButton.enabled = (pageControl.numberOfPages > 1) ? YES : NO;
	[self pageTurn:pageControl];
	[self hideConfirmAndCancel];
}

// 使用者取消刪除
- (void) cancelDelete: (UIButton *) button
{
	[self hideConfirmAndCancel];
}

// 使用者要求刪除目前頁面
- (void) requestDelete: (UIButton *) button
{
	// 顯示取消與確定按鈕
	[cancelButton.superview bringSubviewToFront:cancelButton];
	[confirmButton.superview bringSubviewToFront:confirmButton];
	cancelButton.enabled = YES;
	
	// 將確定按鈕以動畫效果顯示
	confirmButton.center = CGPointMake(deleteButton.center.x - 300.0f, deleteButton.center.y);
	
	[UIView animateWithDuration:0.3f animations:^(void)
    {
        confirmButton.center = deleteButton.center;
    }];
}

// 載入視圖時，設定頁面控制項與捲動視圖
- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
	srandom(time(0));
    
    pageControl.numberOfPages = 0;
	[pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    
	// 建立捲動視圖，設定內容大小與委派
	scrollView = [[UIScrollView alloc] init];
	scrollView.pagingEnabled = YES;
	scrollView.delegate = self;
	[self.view addSubview:scrollView];
    
	// 載入頁面
	for (int i = 0; i < INITPAGES; i++)
        [self addPage];    
    pageControl.currentPage = 0;
	
	// 加大新增按鈕的大小，比較容易點擊
    addButton.frame = CGRectInset(addButton.frame, -20.0f, -20.0f);
}

// 更新視圖畫面編排
- (void) viewDidAppear:(BOOL)animated
{
    dimension = MIN(self.view.bounds.size.width, self.view.bounds.size.height) * 0.8f;
    [self layoutPages];
}

- (void) viewDidLayoutSubviews
{
    [self viewDidAppear:NO];
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