/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <QuartzCore/QuartzCore.h>

#import "RotatingSegue.h"
#import "SwitchedImageViewController.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
#define kAnimationKey @"TransitionViewAnimation"

@implementation RotatingSegue
@synthesize goesForward;
@synthesize delegate;

// 回傳給定視圖的畫面快照
- (UIImage *)screenShot: (UIView *) aView
{
    // 將模糊程度隨意指定為40%，請隨意調整
    UIGraphicsBeginImageContext(hostView.frame.size);
	[aView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextSetRGBFillColor (UIGraphicsGetCurrentContext(), 0, 0, 0, 0.4f);
    CGContextFillRect (UIGraphicsGetCurrentContext(), hostView.frame);
    UIGraphicsEndImageContext();
    return image;
}

// 回傳含有視圖內容的圖層
- (CALayer *) createLayerFromView: (UIView *) aView transform: (CATransform3D) transform
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.anchorPoint = CGPointMake(1.0f, 1.0f);
    imageLayer.frame = (CGRect){.size = hostView.frame.size};
    imageLayer.transform = transform;  
    UIImage *shot = [self screenShot:aView];
    imageLayer.contents = (__bridge id) shot.CGImage;

    return imageLayer;
}

// 開始過場動畫時，移除來源視圖
- (void)animationDidStart:(CAAnimation *)animation 
{
    UIViewController *source = (UIViewController *) super.sourceViewController;
    [source.view removeFromSuperview];
}

// 過場動畫結束時，加入目的地視圖
// 移除動畫，看看委派存不存在
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished 
{
    UIViewController *dest = (UIViewController *) super.destinationViewController;	
    [hostView addSubview:dest.view];
    [transformationLayer removeFromSuperlayer];
    if (delegate)
        SAFE_PERFORM_WITH_ARG(delegate, @selector(segueDidComplete), nil);
}

// 執行過場動畫
-(void)animateWithDuration: (CGFloat) aDuration
{
    CAAnimationGroup *group = [CAAnimationGroup animation]; 
    group.delegate = self; 
    group.duration = aDuration; 
    
    CGFloat halfWidth = hostView.frame.size.width / 2.0f;
    float multiplier = goesForward ? -1.0f : 1.0f;
    
    // 設定x、y、z過場動畫
    CABasicAnimation *translationX = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.x"];
    translationX.toValue = [NSNumber numberWithFloat:multiplier * halfWidth];

    CABasicAnimation *translationZ = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.z"];
    translationZ.toValue = [NSNumber numberWithFloat:-halfWidth];
    
    CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.y"]; 
    rotationY.toValue = [NSNumber numberWithFloat: multiplier * M_PI_2];
    
    // 設定過場動畫的群組
    group.animations = [NSArray arrayWithObjects: rotationY, translationX, translationZ, nil];
    group.fillMode = kCAFillModeForwards; 
    group.removedOnCompletion = NO;
    
	// 執行過場動畫
    [CATransaction flush];
    [transformationLayer addAnimation:group forKey:kAnimationKey];
}

- (void) constructRotationLayer
{
    UIViewController *source = (UIViewController *) super.sourceViewController;
    UIViewController *dest = (UIViewController *) super.destinationViewController;
    hostView = source.view.superview;
    
    // 建立新圖層以便旋轉
    transformationLayer = [CALayer layer];
    transformationLayer.frame = hostView.bounds;
    transformationLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    CATransform3D sublayerTransform = CATransform3DIdentity; 
    sublayerTransform.m34 = 1.0 / -1000;
    [transformationLayer setSublayerTransform:sublayerTransform];   
    [hostView.layer addSublayer:transformationLayer];
    
	// 加入來源視圖，會顯示在前方
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 0);
    [transformationLayer addSublayer:[self createLayerFromView:source.view transform:transform]];
    
    // 準備目的地視圖，右邊或左邊
    // 從主視圖旋轉90/270度
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    transform = CATransform3DTranslate(transform, hostView.frame.size.width, 0, 0);
    if (!goesForward) 
    {
        transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
        transform = CATransform3DTranslate(transform, hostView.frame.size.width, 0, 0);
        transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
        transform = CATransform3DTranslate(transform, hostView.frame.size.width, 0, 0);
    }
    
    [transformationLayer addSublayer:[self createLayerFromView:dest.view transform:transform]];
}

// UIStoryboardSegue的標準方法
- (void)perform
{
    [self constructRotationLayer];
    [self animateWithDuration:0.5f];
}
@end