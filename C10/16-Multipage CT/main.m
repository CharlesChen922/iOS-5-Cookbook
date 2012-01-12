/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "BookController.h"
#import "MarkupHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface CTView : UIView
@property (nonatomic, strong) NSAttributedString *string;
@end

@implementation CTView
@synthesize string;

- (id) initWithAttributedString: (NSAttributedString *) aString
{
	if (!(self = [super initWithFrame:CGRectZero])) return self;
    
	self.backgroundColor = [UIColor clearColor];
	string = aString;
	
	return self;
}

- (void) drawRect:(CGRect)rect
{
	[super drawRect: rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0); // 翻轉內文
    
    [[UIColor scrollViewTexturedBackgroundColor] set];
    CGContextFillRect(context, self.frame);
    
    [[UIColor whiteColor] set];
    CGRect insetWhite = CGRectInset(self.frame, 10.0f, 10.0f);
    CGContextFillRect(context, insetWhite);
	
	// 從視圖的邊緣稍微往內縮
	CGMutablePathRef path = CGPathCreateMutable();
    CGFloat inset = IS_IPAD ? 30.0f : 15.0f;
    CGRect insetRect = CGRectInset(self.frame, inset, inset);
	CGPathAddRect(path, NULL, insetRect);
    
	// 繪製文字
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.string.length), path, NULL);
	CTFrameDraw(theFrame, context);
	
	CFRelease(framesetter);
	CFRelease(path);
	CFRelease(theFrame);
}
@end

@interface TestBedViewController : UIViewController <BookControllerDelegate>
{
    BookController *bookController;
    NSAttributedString *attributed;
    NSArray *pageArray;
}
@end

@implementation TestBedViewController
- (NSArray *) findPageSplitsForString: (NSAttributedString *) theString withPageSize: (CGSize) pageSize
{
    NSInteger stringLength = theString.length;
    NSMutableArray *pages = [NSMutableArray array];

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) theString);
    
    CFRange baseRange = {0,0};
    CFRange targetRange = {0,0};
    do {
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, baseRange, NULL, pageSize, &targetRange);
        NSRange destRange = {baseRange.location, targetRange.length};
        [pages addObject:[NSValue valueWithRange:destRange]];
        baseRange.location += targetRange.length;
    } while(baseRange.location < stringLength);
    
    CFRelease(frameSetter);
    return pages;
}

// 根據給定的頁面編號，提供視圖控制器
- (id) viewControllerForPage: (int) pageNumber
{    
    if (pageNumber < 0) return nil;
    
    // 在本文前插入一頁，在最後（奇數）頁之後插入一頁
    if ((pageNumber == 0) ||
        (pageNumber == pageArray.count + 1))
    {
        UIViewController *rc = [BookController rotatableViewController];
        rc.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        return rc;
    }
    
    if (pageNumber > pageArray.count) return nil;
    
    // 調整頁面數目，減去前面插入的起始書頁
    pageNumber--;
    
    // 建立新控制器
    UIViewController *controller = [BookController rotatableViewController];
    
    // 找出需要顯示的文字
    NSRange offsetRange = [[pageArray objectAtIndex:pageNumber] rangeValue];
    NSAttributedString *subString = [attributed attributedSubstringFromRange:offsetRange];

    // 加入子視圖
    CGRect appRect = (CGRect) {.size = [[UIScreen mainScreen] applicationFrame].size};
    CTView *ct = [[CTView alloc] initWithAttributedString:subString];
    ct.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    ct.frame = appRect;
    [controller.view addSubview:ct];

    // 回傳新控制器
    return controller;
}

- (void) viewDidLoad
{
    // 加入子控制器，設為第一頁
    [self.view addSubview:bookController.view];
    [self addChildViewController:bookController];
    [bookController didMoveToParentViewController:self];
    [bookController moveToPage:0];
}

- (void) loadView
{
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSString *markup = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    attributed = [MarkupHelper stringFromMarkup:markup];

    // 建立頁面視圖控制器
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    bookController = [BookController bookWithDelegate:self];
    bookController.view.frame = (CGRect){.size = appRect.size};
    
    CGFloat inset = 2.0f * (IS_IPAD ? 30.0f : 15.0f);
    CGSize flip = CGSizeMake(appRect.size.height - inset, (appRect.size.width / 2.0f) - inset);
    pageArray = [self findPageSplitsForString:attributed withPageSize:flip];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
    window.rootViewController = tbvc;
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