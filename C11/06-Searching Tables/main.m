/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]
#define CRAYON_COLOR(CRAYON) getColor([[CRAYON componentsSeparatedByString:@"#"] lastObject])
#define DEFAULTKEYS [crayonColors.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]
#define FILTEREDKEYS [filteredArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]

#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// 將由六個16進位數字組成的顏色值，轉為UIColor物件
UIColor *getColor(NSString *hexColor)
{
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];	
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

@interface TestBedViewController : UITableViewController <UISearchBarDelegate>
{
	NSMutableDictionary *crayonColors;
    NSArray *filteredArray;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
    
    NSMutableArray *sectionArray;
}
@end

@implementation TestBedViewController

// 回傳區段資料文字的第一個字母
- (NSString *) firstLetter: (NSInteger) section
{
    return [[ALPHA substringFromIndex:section] substringToIndex:1];
}

// 回傳含有區段項目資料的陣列
- (NSArray *) itemsInSection: (NSInteger) section
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", [self firstLetter:section]];
    return [crayonColors.allKeys filteredArrayUsingPredicate:predicate];
}

// 在區段索引裡加入搜尋放大鏡圖示
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView 
{
	if (aTableView == self.tableView)  // 一般表格
	{
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < sectionArray.count; i++)
			if ([[sectionArray objectAtIndex:i] count])
				[indices addObject:[self firstLetter:i]];

        return indices;
	}
	else return nil; // 搜尋表格
}

// 根據給定標頭文字，找到相對應的區段編號
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (title == UITableViewIndexSearch) 
	{
		[self.tableView scrollRectToVisible:searchBar.frame animated:NO];
		return -1;
	}
	return [ALPHA rangeOfString:title].location;
}

// 回傳某區段的標頭文字
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if (aTableView == self.tableView) 
	{
		if ([[sectionArray objectAtIndex:section] count] == 0) return nil;
		return [NSString stringWithFormat:@"Crayon names starting with '%@'", [self firstLetter:section]];
	}
	else return nil;
}

// 回傳表格裡有幾個區段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
    if (aTableView == self.tableView) return sectionArray.count;
    return 1; 
}

// 回傳某區段裡有幾列
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	// 一般表格
	if (aTableView == self.tableView) 
        return [[sectionArray objectAtIndex:section] count];
	
	// 搜尋表格
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchBar.text];
	filteredArray = [crayonColors.allKeys filteredArrayUsingPredicate:predicate];
	return filteredArray.count;
}

// 根據給定的索引路徑，回傳儲存格
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 從佇列裡取得儲存格重複使用，或建立新的
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] ;  
    
	// 取得crayon（蠟筆）與它的顏色
    NSArray *currentItems = [sectionArray objectAtIndex:indexPath.section];
	NSArray *keyCollection = (aTableView == self.tableView) ? currentItems : FILTEREDKEYS;
	NSString *crayon = [keyCollection objectAtIndex:indexPath.row];
    
	// 更新儲存格
	cell.textLabel.text = crayon;
	if (![crayon hasPrefix:@"White"])
		cell.textLabel.textColor = [crayonColors objectForKey:crayon];
	else
		cell.textLabel.textColor = [UIColor blackColor];
	return cell;
}

// 使用者點選時，更新導覽列的漸層顏色
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSArray *currentItems = [sectionArray objectAtIndex:indexPath.section];
	NSArray *keyCollection = (aTableView == self.tableView) ? currentItems : FILTEREDKEYS;
	NSString *crayon = [keyCollection objectAtIndex:indexPath.row];
    
    UIColor *crayonColor = [crayonColors objectForKey:crayon];
	self.navigationController.navigationBar.tintColor = crayonColor;
	searchBar.tintColor = crayonColor;
}

// 從Jack Lucky來的。 Cancel按鈕，重置搜尋關鍵字
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
	[searchBar setText:@""]; 
}

// 顯示到畫面上時，將搜尋列捲到外面
- (void) viewDidAppear:(BOOL)animated
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


- (void) loadView
{
    [super loadView];

	// 準備含有crayon（蠟筆）顏色的字典
	NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt" inDirectory:@"/"];
	NSArray *rawCrayons = [[NSString stringWithContentsOfFile:pathname encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	crayonColors = [NSMutableDictionary dictionary];
	for (NSString *string in rawCrayons) 
		[crayonColors setObject:CRAYON_COLOR(string) forKey:CRAYON_NAME(string)];
    
    sectionArray = [NSMutableArray array];
    for (int i = 0; i < 26; i++)
        [sectionArray addObject:[self itemsInSection:i]];
    
    // 建立搜尋列
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	searchBar.tintColor = COOKBOOK_PURPLE_COLOR;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
	self.tableView.tableHeaderView = searchBar;
	
	// 建立搜尋顯示控制器
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
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