//
//  VIDEOkit.m
//  HelloWorld
//
//  Created by Erica Sadun on 5/12/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import "VIDEOkit.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

#define SCREEN_CONNECTED	([UIScreen screens].count > 1)

@implementation VIDEOkit
@synthesize delegate;
@synthesize outwindow, displayLink;

static VIDEOkit *sharedInstance = nil;

- (void) setupExternalScreen
{
	// 檢查有無連接
	if (!SCREEN_CONNECTED) return;
	
	// 設定外接螢幕
	UIScreen *secondaryScreen = [[UIScreen screens] objectAtIndex:1];
	UIScreenMode *screenMode = [[secondaryScreen availableModes] lastObject];
	CGRect rect = (CGRect){.size = screenMode.size};
	NSLog(@"Extscreen size: %@", NSStringFromCGSize(rect.size));
	
	// 建立新的視窗給外接螢幕
	self.outwindow = [[UIWindow alloc] initWithFrame:CGRectZero];
	outwindow.screen = secondaryScreen;
	outwindow.screen.currentMode = screenMode; // 感謝Scott Lawrence
	[outwindow makeKeyAndVisible];
	outwindow.frame = rect;

	// 加入視圖給outwindow
	baseView = [[UIImageView alloc] initWithFrame:rect];
	baseView.backgroundColor = [UIColor darkGrayColor];
	[outwindow addSubview:baseView];

	// 回復原本的主視窗的狀態
	[delegate.view.window makeKeyAndVisible];
}

- (void) updateScreen
{
	// 若外接螢幕已經被拔除，就終止
	if (!SCREEN_CONNECTED && outwindow)
		self.outwindow = nil;
	
	// （再）初始化，如果沒有輸出視窗的話
	if (SCREEN_CONNECTED && !outwindow)
		[self setupExternalScreen];
	
	// 如果遇到奇怪的錯誤，終止
	if (!self.outwindow) return;
	
	// 繼續更新
    SAFE_PERFORM_WITH_ARG(delegate, @selector(updateExternalView:), baseView);
}

- (void) screenDidConnect: (NSNotification *) notification
{
    NSLog(@"Screen connected");
    UIScreen *screen = [[UIScreen screens] lastObject];
    
    if (displayLink)
    {
        [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [displayLink invalidate];
        self.displayLink = nil;
    }
    
    // Check for current display link
    if (!displayLink)
    {
        self.displayLink = [screen displayLinkWithTarget:self selector:@selector(updateScreen)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void) screenDidDisconnect: (NSNotification *) notification
{
	NSLog(@"Screen disconnected.");
    if (displayLink)
    {
        [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [displayLink invalidate];
        self.displayLink = nil;
    }
}

- (id) init
{
	if (!(self = [super init])) return self;
	
	// 處理外接螢幕的視窗
	if (SCREEN_CONNECTED) 
        [self screenDidConnect:nil];
	
	// 註冊外接螢幕連接∕拔除的通知
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];

	return self;
}

- (void) dealloc
{
    [self screenDidDisconnect:nil];
	self.outwindow = nil;
}

+ (VIDEOkit *) sharedInstance
{
	if (!sharedInstance)	
		sharedInstance = [[self alloc] init];
	return sharedInstance;
}

+ (void) startupWithDelegate: (id) aDelegate
{
    [[self sharedInstance] setDelegate:aDelegate];
}
@end
