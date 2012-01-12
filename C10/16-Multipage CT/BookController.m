/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

/*
 關於這個類別:
 
 - 西式書本，從左到右的翻頁形式
 - 在橫擺時呈現兩頁，直擺時呈現一頁
 - 會記錄目前頁面，但不使用 
 */


#import "BookController.h"

#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define SAFE_ADD(_Array_, _Object_) {if (_Object_ && [_Array_ isKindOfClass:[NSMutableArray class]]) [pageControllers addObject:_Object_];}
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)


#pragma Utility Class - VC that Rotates
@interface RotatableVC : UIViewController 
@end
@implementation RotatableVC
- (void) loadView 
{
    [super loadView]; 
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor whiteColor];
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}
@end


#pragma Book Controller
@implementation BookController
@synthesize bookDelegate, pageNumber;

#pragma mark Debug / Utility
- (int) currentPage
{
    int pageCheck = ((UIViewController *)[self.viewControllers objectAtIndex:0]).view.tag;
    return pageCheck;
}

#pragma mark Page Handling

// 若你想使用其他風格的寫法，請自行修改
- (BOOL) useSideBySide: (UIInterfaceOrientation) orientation
{
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    return isLandscape;
}

// 更新目前頁面，記錄下來，呼叫委派
- (void) updatePageTo: (uint) newPageNumber
{
    pageNumber = newPageNumber;
    
    [[NSUserDefaults standardUserDefaults] setInteger:pageNumber forKey:DEFAULTS_BOOKPAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];

    SAFE_PERFORM_WITH_ARG(bookDelegate, @selector(bookControllerDidTurnToPage:), [NSNumber numberWithInt:pageNumber]);
}

// 向委派請求控制器
- (UIViewController *) controllerAtPage: (int) aPageNumber
{
    if (bookDelegate && 
        [bookDelegate respondsToSelector:@selector(viewControllerForPage:)])
    {
        UIViewController *controller = [bookDelegate viewControllerForPage:aPageNumber];
        controller.view.tag = aPageNumber;
        return controller;
    }
    return nil;
}

// 根據給定頁面，更新畫面
- (void) fetchControllersForPage: (uint) requestedPage orientation: (UIInterfaceOrientation) orientation
{
    BOOL sideBySide = [self useSideBySide:orientation];
    int numberOfPagesNeeded = sideBySide ? 2 : 1;
    int currentCount = self.viewControllers.count;
    
    uint leftPage = requestedPage;
    if (sideBySide && (leftPage % 2)) leftPage--;
    
    // 當數目相符時，才對目前頁面進行檢查
    if (currentCount && (currentCount == numberOfPagesNeeded))
    {
        if (pageNumber == requestedPage) return;
        if (pageNumber == leftPage) return;
    }
    
    // 根據新舊頁面，決定翻頁方向
    UIPageViewControllerNavigationDirection direction = (requestedPage > pageNumber) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self updatePageTo:requestedPage];
    
    // 更新控制器
    NSMutableArray *pageControllers = [NSMutableArray array];
    SAFE_ADD(pageControllers, [self controllerAtPage:leftPage]);    
    if (sideBySide)
        SAFE_ADD(pageControllers, [self controllerAtPage:leftPage + 1]);
    
    [self setViewControllers:pageControllers direction: direction animated:YES completion:nil];
}

// 外界而來的翻頁指令
- (void) moveToPage: (uint) requestedPage
{
    [self fetchControllersForPage:requestedPage orientation:(UIInterfaceOrientation)[UIDevice currentDevice].orientation];
}

#pragma mark Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    [self updatePageTo:pageNumber + 1];
    return [self controllerAtPage:(viewController.view.tag + 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    [self updatePageTo:pageNumber - 1];
    return [self controllerAtPage:(viewController.view.tag - 1)];
}

#pragma mark Delegate

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSUInteger indexOfCurrentViewController = 0;
    if (self.viewControllers.count)
        indexOfCurrentViewController = ((UIViewController *)[self.viewControllers objectAtIndex:0]).view.tag;
    [self fetchControllersForPage:indexOfCurrentViewController orientation:orientation];
    
    BOOL sideBySide = [self useSideBySide:orientation];
    self.doubleSided = sideBySide;
    
    UIPageViewControllerSpineLocation spineLocation = sideBySide ? UIPageViewControllerSpineLocationMid : UIPageViewControllerSpineLocationMin;
    return spineLocation;
}

#pragma mark Class utility routines
// 回傳知道如何旋轉的UIViewController
+ (id) rotatableViewController
{
    UIViewController *vc = [[RotatableVC alloc] init];
    return vc;
}

// 回傳新的BookController
+ (id) bookWithDelegate: (id) theDelegate
{
    BookController *bc = [[BookController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    bc.dataSource = bc;
    bc.delegate = bc;
    bc.bookDelegate = theDelegate;
    
    return bc;
}
@end
