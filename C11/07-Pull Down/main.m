/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UITableViewController <UIScrollViewDelegate>
{
    int numberOfItems;
	BOOL addItemsTrigger;
}
@end

@implementation TestBedViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
    return numberOfItems;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// 偵測有無觸發，若有，加入新項目並重新載入表格
	if (addItemsTrigger)
	{
		numberOfItems += 2;
		[self.tableView reloadData];
	}
    
	// 重置觸發旗標
	addItemsTrigger = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	// 若使用者往回捲超過50點，進行觸發
	if (scrollView.contentOffset.y < -50.0f)
		addItemsTrigger = YES;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 從佇列裡取得儲存格重複使用，或建立新的
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] ;
	
	cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", numberOfItems - indexPath.row];
	return cell;
}

- (void) loadView
{
    [super loadView];
    numberOfItems = 3; // 一開始先顯示幾個儲存格
    
	// 把自己設為捲動視圖的委派物件，擷取捲動事件
	self.tableView.delegate = self;
	self.tableView.autoresizesSubviews = YES;
	
	// 把「Pull to Load（下拉代表載入）」放在表格上
	UIView *pullView = [[[NSBundle mainBundle] loadNibNamed:@"HiddenHeaderView" owner:self options:nil] lastObject]; 
	pullView.frame = CGRectOffset(pullView.frame, 0.0f, -pullView.frame.size.height);
	[self.tableView addSubview:pullView];
    
    self.title = @"Pull-down Demo";
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