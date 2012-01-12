/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "StringHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

CGRect rectCenteredInRect(CGRect rect, CGRect mainRect)
{
	return CGRectOffset(rect, 
						CGRectGetMidX(mainRect)-CGRectGetMidX(rect),
						CGRectGetMidY(mainRect)-CGRectGetMidY(rect));
}

@interface BigTextView : UIView
{
	UIFont *textFont;
	CGSize textSize;
	int fontSize;	
}
@property (nonatomic, retain) NSString *string;
+ (void) bigTextWithString:(NSString *)theString;
@end

@implementation BigTextView
@synthesize string;
- (void) drawRect:(CGRect)rect
{
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// 翻轉座標，往內縮足夠的距離，才不會跟狀態列起衝突
	CGRect flipRect = CGRectMake(0.0f, 0.0f, self.frame.size.height, self.frame.size.width);
	flipRect = CGRectInset(flipRect, 24.0f, 24.0f);
    
	// 迭代，直到找到適當的一組字型樣式，能夠符合矩形大小
    // 感謝QuickSilver可愛的開發人員給我的靈感
	for(fontSize = 18; fontSize < 300; fontSize++ ) 
	{
		textFont = [UIFont boldSystemFontOfSize:fontSize+1];
		textSize = [string sizeWithFont:textFont];
		if (textSize.width > (flipRect.size.width + ([textFont descender] * 2)))
			break;
	}
	
	// 初始化StringHelper ，使用上面找到的字型樣式
	StringHelper *shelper = [StringHelper buildHelper];
	shelper.fontSize = fontSize;
	shelper.foregroundColor = [UIColor whiteColor];
	shelper.alignment = @"Center";
	shelper.fontName = @"GeezaPro-Bold";
	[shelper appendFormat:@"%@", string];
    
	// 找出可以包含文字的最大frame
	CGRect textFrame = CGRectZero;
	textFrame.size = [string sizeWithFont:[UIFont fontWithName:shelper.fontName size:shelper.fontSize]];
	
	// 在翻轉後的矩形裡，將目的地矩形置中
	CGRect centerRect = rectCenteredInRect(textFrame, flipRect);
    
	// 翻轉座標，以正確方向顯示文字
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	// 旋轉90度，靠著視窗的垂直軸，繪製文字
	CGContextRotateCTM(context, -M_PI_2);
	CGContextTranslateCTM(context, -self.frame.size.height, 0.0f);
	
	// 繪製灰色底圖
	[[UIColor grayColor] set];
	CGRect insetRect = CGRectInset(centerRect, -20.0f, -20.0f);
	[[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:32.0f] fill];
	CGContextFillPath(context);
    
	// 建立路徑，繪製文字的地方
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, centerRect);
	
	// 繪製文字
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)shelper.string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, shelper.string.length), path, NULL);
	CTFrameDraw(theFrame, context);
	
	// 結束清理
	CFRelease(framesetter);
	CFRelease(path);
	CFRelease(theFrame);	
}

+ (void) bigTextWithString:(NSString *)theString
{
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	BigTextView *btv = [[BigTextView alloc] initWithFrame:keyWindow.bounds];
	btv.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5f];
	btv.string = theString;
	[keyWindow addSubview:btv];
	
	return;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self removeFromSuperview];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) action: (id) sender
{
	[BigTextView bigTextWithString:@"303-555-1212"];
}

- (void) viewDidAppear:(BOOL)animated
{
	[BigTextView bigTextWithString:@"303-555-1212"];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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