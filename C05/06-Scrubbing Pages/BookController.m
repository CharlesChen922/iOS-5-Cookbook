/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "BookController.h"

#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define DEFAULTS_BOOKPAGE   @"BookControllerMostRecentPage"
#define SAFE_ADD(_Array_, _Object_) {if (_Object_ && [_Array_ isKindOfClass:[NSMutableArray class]]) [pageControllers addObject:_Object_];}
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)


#pragma Utility Class - VC that Rotates
@interface RotatableVC : UIViewController 
@end
@implementation RotatableVC
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {return YES;}
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
// 如果你想使用其他種寫法，請自行更改
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

// 向委派要求控制器
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

// 更新顯示頁面
- (void) fetchControllersForPage: (uint) requestedPage orientation: (UIInterfaceOrientation) orientation
{
    BOOL sideBySide = [self useSideBySide:orientation];
    int numberOfPagesNeeded = sideBySide ? 2 : 1;
    int currentCount = self.viewControllers.count;

    uint leftPage = requestedPage;
    if (sideBySide && (leftPage % 2)) leftPage--;
   
    // 只有在數目正確時，才對目前頁面進行檢查
    if (currentCount && (currentCount == numberOfPagesNeeded))
    {
        if (pageNumber == requestedPage) return;
        if (pageNumber == leftPage) return;
    }
    
    // 比較新舊頁面，決定翻頁方向
    UIPageViewControllerNavigationDirection direction = (requestedPage > pageNumber) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self updatePageTo:requestedPage];
    
    // 更新控制器，絕對不能加入nil
    NSMutableArray *pageControllers = [NSMutableArray array];
    SAFE_ADD(pageControllers, [self controllerAtPage:leftPage]);    
    if (sideBySide)
        SAFE_ADD(pageControllers, [self controllerAtPage:leftPage + 1]);
    
    [self setViewControllers:pageControllers direction: direction animated:YES completion:nil];
}

// 從外界而來的翻頁請求
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
    // 從左邊的頁面，或從單一頁面開始
    NSUInteger indexOfCurrentViewController = 0;
    if (self.viewControllers.count)
        indexOfCurrentViewController = ((UIViewController *)[self.viewControllers objectAtIndex:0]).view.tag;
    [self fetchControllersForPage:indexOfCurrentViewController orientation:orientation];
    
    // 決定要不要一次呈現兩頁
    BOOL sideBySide = [self useSideBySide:orientation];
    self.doubleSided = sideBySide;
    
    UIPageViewControllerSpineLocation spineLocation = sideBySide ? UIPageViewControllerSpineLocationMid : UIPageViewControllerSpineLocationMin;
    return spineLocation;
}

#pragma mark Class utility routines
// 回傳知道如何旋轉的UIViewController
+ (id) rotatableViewController
{
    return [[RotatableVC alloc] init];
}

// 回傳新書本
+ (id) bookWithDelegate: (id) theDelegate
{
    BookController *bc = [[BookController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    bc.dataSource = bc;
    bc.delegate = bc;
    bc.bookDelegate = theDelegate;

    // 這個範例裡，共享所有頁面，若程式裡使用多個書本控制器，需要修改
    bc.pageNumber = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_BOOKPAGE])
        bc.pageNumber = [[NSUserDefaults standardUserDefaults] integerForKey:DEFAULTS_BOOKPAGE];
    [bc moveToPage:bc.pageNumber];

    return bc;
}
@end
