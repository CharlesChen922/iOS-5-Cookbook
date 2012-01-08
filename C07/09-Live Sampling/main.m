/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "Geometry.h"
#import "Orientation.h"
#import "Colors.h"

#import "UIImage-Utilities.h"
#import "CameraImageHelper.h"

@interface TestBedViewController : UIViewController
{
    CameraImageHelper *helper;
}
@end

@implementation TestBedViewController

- (void) switch: (id) sender
{
    [helper switchCameras];
}

#define SAMPLE_LENGTH	128

- (void) pickColor
{
	// 取出中央的128x128區域當樣本
    UIImage *currentImage = helper.currentImage;
    CGRect sampleRect = CGRectMake(0.0f, 0.0f, SAMPLE_LENGTH, SAMPLE_LENGTH);
    sampleRect = CGRectCenteredInRect(sampleRect, (CGRect){.size = currentImage.size});
    
    UIImage *sampleImage = [currentImage subImageWithBounds:sampleRect];
    
	unsigned char *bits = [sampleImage createBitmap];
	
	int bucket[360];
	CGFloat sat[360], bri[360];
	
	// 建立柱狀圖，取得每一取樣色調的平均飽和度與平均明亮度
	for (int i = 0; i < 360; i++) 
	{
		bucket[i] = 0; // 柱狀圖取樣
		sat[i] = 0.0f; // 平均飽和度
		bri[i] = 0.0f; // 平均明亮度
	}
	
	// 迭代每個取樣像素，收集hsb資訊
	for (int y = 0; y < SAMPLE_LENGTH; y++)
		for (int x = 0; x < SAMPLE_LENGTH; x++)
		{			
			CGFloat r = ((CGFloat)bits[redOffset(x, y, SAMPLE_LENGTH)] / 255.0f);
			CGFloat g = ((CGFloat)bits[greenOffset(x, y, SAMPLE_LENGTH)] / 255.0f);
			CGFloat b = ((CGFloat)bits[blueOffset(x, y, SAMPLE_LENGTH)] / 255.0f);
			
			// 把RGB轉為HSV
			CGFloat h, s, v;
			rgbtohsb(r, g, b, &h, &s, &v);
			int hue = (hue > 359.0f) ? 0 : (int) h;
			
			// 對每一色調進行統計
			bucket[hue]++;
			sat[hue] += s;
			bri[hue] += v;
		}
	
	// 取回色調模式
	int max = -1;
	int maxVal = -1;
	for (int i = 0; i < 360; i++)
	{
		if (bucket[i]  > maxVal)
		{
			max = i;
			maxVal = bucket[i];
		}
	}
	
	// 根據色調模式、平均飽和度、平均明亮度建立顏色
	float h = max / 360.0f;
	float s = sat[max]/maxVal;
	float br = bri[max]/maxVal;
	
	UIColor *hueColor = [UIColor colorWithHue:h saturation:s brightness:br alpha:1.0f];
	
    // 顯示選出來的顏色
    self.navigationController.navigationBar.tintColor = hueColor;
    
    free(bits);
}


- (void) viewDidLayoutSubviews
{
    [helper layoutPreviewInView:self.view];
}

- (void) loadView
{
    [super loadView];
    self.view.frame = (CGRect){.size = [[UIScreen mainScreen] applicationFrame].size};
    RESIZABLE(self.view);
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // Switch between cameras
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switch:));
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Process", @selector(process:));
    
    helper = [CameraImageHelper helperWithCamera:kCameraFront];
    [helper startRunningSession];

    [helper embedPreviewInView:self.view];
    
    [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(pickColor) userInfo:nil repeats:YES];
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