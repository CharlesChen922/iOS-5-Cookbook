/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ToDoItem.h"

#define COOKBOOK_PURPLE_COLOR    [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR)     [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

@interface TestBedViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext *context;
    NSFetchedResultsController *fetchedResultsController;
}
- (void) setBarButtonItems;
@end

@implementation TestBedViewController
- (void) performFetch
{
    // 初始化取回請求
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100]; // 比本範例所需還要大
    
    // 上升型排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"action" ascending:YES selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    // 初始化取回結果控制器
    NSError *error;
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"sectionName" cacheName:nil];
    fetchedResultsController.delegate = self;
    if (![fetchedResultsController performFetch:&error])    
        NSLog(@"Error: %@", [error localizedFailureReason]);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self setBarButtonItems];
}

#pragma mark Table Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    // 回傳給定區段的標題
    NSArray *titles = [fetchedResultsController sectionIndexTitles];
    if (titles.count <= section) return @"Error";
    return [titles objectAtIndex:section];
}

#pragma mark Items in Sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取得或建立新儲存格
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basic cell"];
    
    // 從取回結果裡，找出物件
    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:@"action"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    // 在此執行動作
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO;     // 不允許調整順序
}

#pragma mark Data
- (void) setBarButtonItems
{
    // 左項目一定為Add新增
    self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(add));
    
    // 右項目（Edit編輯∕Done完成）one) ，根據編輯模式與項目個數而定
    int count = [[fetchedResultsController fetchedObjects] count];
    if (self.tableView.isEditing)
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
    else
        self.navigationItem.rightBarButtonItem =  count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
}

-(void)enterEditMode
{
    // 開始編輯
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView setEditing:YES animated:YES];
    [self setBarButtonItems];
}

-(void)leaveEditMode
{
    // 結束編輯
    [self.tableView setEditing:NO animated:YES];
    [self setBarButtonItems];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // 刪除
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        NSError *error = nil;
        [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    }
    
    [self performFetch];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    
    NSString *todoAction = [alertView textFieldAtIndex:0].text;
    if (!todoAction || todoAction.length == 0) return;
    
    ToDoItem *item = (ToDoItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:context];
    item.action = todoAction;
    item.sectionName = [[todoAction substringToIndex:1] uppercaseString];
    
    // 儲存新項目
    NSError *error; 
    if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    
    [self performFetch];
}

- (void) add
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"To Do" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

- (void) initCoreData
{
    NSError *error;
    
    // sqlite檔的路徑 
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/todo.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // 初始化模型、協調者、內文
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) 
        NSLog(@"Error: %@", [error localizedFailureReason]);
    else
    {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    
    [self initCoreData];
    [self performFetch];
    [self setBarButtonItems];
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