/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define NUMSTR(_aNumber_) [NSString stringWithFormat:@"%d", _aNumber_]

@interface NSMutableDictionary (Boolean)
- (BOOL) boolForKey: (NSString *) aKey;
- (void) setBool: (BOOL) boolValue ForKey: (NSString *) aKey;
@end

@implementation NSMutableDictionary (Boolean)
- (BOOL) boolForKey: (NSString *) aKey
{
    if (![self objectForKey:aKey]) return NO;
    
    id obj = [self objectForKey:aKey];
    
    if ([obj respondsToSelector:@selector(boolValue)])
        return [(NSNumber *)obj boolValue];
    
    return NO;
}

- (void) setBool: (BOOL) boolValue ForKey: (NSString *) aKey
{
    [self setObject:[NSNumber numberWithBool:boolValue] forKey:aKey];
}
@end

@interface TestBedViewController : UITableViewController
{
    NSArray *items;
    NSMutableDictionary *switchStates;
}
@end

@implementation TestBedViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	// 這個簡單的表格只有一個區段
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	// 回傳列數目
	return items.count;
}

- (void) toggleSwitch: (UISwitch *) aSwitch
{
    // 儲存作用中的開關的狀態
    [switchStates setBool:aSwitch.isOn ForKey:NUMSTR(aSwitch.superview.tag)];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 使用內建的nib載入器
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CustomCell"];

    // 取得開關，有需要的話加入目標
    UISwitch *switchView = (UISwitch *)[cell viewWithTag:99];
    if (![switchView allTargets].count)
        [switchView addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    
	// 設定儲存格的標籤
	cell.textLabel.text = [items objectAtIndex:indexPath.row];
    
    // 移除底下這行，觀察「錯」的程式行為
    switchView.on = [switchStates boolForKey:NUMSTR(indexPath.row)];
    
   // 賦予標號給儲存格的contentView，開關需要這個數字
    cell.contentView.tag = indexPath.row;
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // 回應使用者的操作動作
    self.title = [items objectAtIndex:indexPath.row];
}

- (void) loadView
{
    [super loadView];
    items = [@"A*B*C*D*E*F*G*H*I*J*K*L*M*N*O*P*Q*R*S*T*U*V*W*X*Y*Z" componentsSeparatedByString:@"*"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CustomCell"];
    
    self.tableView.backgroundColor = [UIColor clearColor];

    switchStates = [NSMutableDictionary dictionary];
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