/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ReflectingView.h"

@implementation ReflectingView
@synthesize usesGradientOverlay;

// 一定使用複製者圖層
+ (Class) layerClass
{
    return [CAReplicatorLayer class];
}

// 清除父圖層裡任何已存在的漸層效果
- (void) dealloc
{
    [gradient removeFromSuperlayer];
}

- (void) setupGradient
{
    // 加入新漸層圖層到父視圖裡
    UIView *parent = self.superview;
    if (!gradient)
    {
        gradient = [CAGradientLayer layer];
        CGColorRef c1 = [[UIColor blackColor] colorWithAlphaComponent:0.5f].CGColor;
        CGColorRef c2 = [[UIColor blackColor] colorWithAlphaComponent:0.9f].CGColor;
        [gradient setColors:[NSArray arrayWithObjects:
                             (__bridge id)c1, (__bridge id)c2, nil]];
        [parent.layer addSublayer:gradient];
    }
    
    // 使用倒影的位置，將漸層放在視圖的下方
    float desiredGap = 10.0f;
    CGFloat shrinkFactor = 0.25f;
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    CGFloat y = self.frame.origin.y;
    
    [gradient setAnchorPoint:CGPointMake(0.0f,0.0f)];
    [gradient setFrame:CGRectMake(0.0f, y + height + desiredGap, width, height * shrinkFactor)];
    [gradient removeAllAnimations];
}

- (void) setupReflection
{
    CGFloat height = self.bounds.size.height;
    CGFloat shrinkFactor = 0.25f;
    
    CATransform3D t = CATransform3DMakeScale(1.0, -shrinkFactor, 1.0);
    
    // 以倒影中心進行縮放，以縮放後的尺度進行位移
    float offsetFromBottom = height * ((1.0f - shrinkFactor) / 2.0f);
    float inverse = 1.0 / shrinkFactor;
    float desiredGap = 10.0f;
    t = CATransform3DTranslate(t, 0.0, -offsetFromBottom * inverse - height - inverse * desiredGap, 0.0f);
    
    CAReplicatorLayer *replicatorLayer = (CAReplicatorLayer*)self.layer;
    replicatorLayer.instanceTransform = t;
    replicatorLayer.instanceCount = 2;
    
    // 必須明確地設定漸層
    if (usesGradientOverlay)
        [self setupGradient];
    else
    {
        // 若不使用漸層時，將倒影變黑一點
        replicatorLayer.instanceRedOffset = -0.75;
        replicatorLayer.instanceGreenOffset = -0.75;
        replicatorLayer.instanceBlueOffset = -0.75;
    }
}
@end