/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR]

@interface TestBedViewController : UITableViewController
{
    NSMutableArray *items;
    int count;
}
@end

@implementation TestBedViewController

#pragma mark Table contents
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	// 這個簡單的表格，只有一個區段
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	// 回傳項目的個數
	return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 從佇列取出儲存格重複使用，或是建立新的
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
    
	if (!cell) 
		cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    
	cell.textLabel.text = [items objectAtIndex:indexPath.row];
	return cell;
}


#pragma mark Edits
- (void) setBarButtonItems
{
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(addItem:));
	
	if (self.tableView.isEditing)
		self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
	else
		self.navigationItem.rightBarButtonItem = items.count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
}

-(void)enterEditMode
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self.tableView setEditing:YES animated:YES];
	[self setBarButtonItems];
}

-(void)leaveEditMode
{
	[self.tableView setEditing:NO animated:YES];
	[self setBarButtonItems];
}

- (void) updateItemAtIndexPath: (NSIndexPath *) indexPath withString: (NSString *) string
{
    // 在執行編輯動作前，建立復原動作
    NSString *undoString = string ? nil : [items objectAtIndex:indexPath.row];
	[[self.undoManager prepareWithInvocationTarget:self] updateItemAtIndexPath:indexPath withString:undoString];

	// 傳入nil代表刪除
	if (!string) 
		[items removeObjectAtIndex:indexPath.row];
	else 
		[items insertObject:string atIndex:indexPath.row];
	
	[self.tableView reloadData];
	[self setBarButtonItems];
}

- (void) addItem: (id) sender
{
	// 加入新項目
	NSIndexPath *newPath = [NSIndexPath indexPathForRow:items.count inSection:0];
	NSString *newTitle = [NSString stringWithFormat:@"Item %d", ++count];
	[self updateItemAtIndexPath:newPath withString:newTitle];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// 刪除項目
	[self updateItemAtIndexPath:indexPath withString:nil];
}

#pragma mark reordering
-(void) tableView: (UITableView *) tableView moveRowAtIndexPath: (NSIndexPath *) oldPath toIndexPath:(NSIndexPath *) newPath
{
	if (oldPath.row == newPath.row) return;
	
	[[self.undoManager prepareWithInvocationTarget:self] tableView:self.tableView moveRowAtIndexPath:newPath toIndexPath:oldPath];
	
	NSString *item = [items objectAtIndex:oldPath.row];
	[items removeObjectAtIndex:oldPath.row];
	[items insertObject:item atIndex:newPath.row];
	
	[self setBarButtonItems];
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25f];
}

#pragma mark Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // 在此回應使用者的點選
}

#pragma mark First Responder for Undo Support
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

#pragma mark View Controller
- (void) loadView
{
    [super loadView];
    items = [NSMutableArray arrayWithArray:[@"A*B*C*D*E" componentsSeparatedByString:@"*"]];
    [self setBarButtonItems];
    
    // 支援復原Undo
    self.tableView.undoManager.levelsOfUndo = 999;    
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
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