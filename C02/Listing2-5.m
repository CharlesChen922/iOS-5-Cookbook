/* 列表2-5：為UIDevice建立裝置擺設方向類目 */

@interface UIDevice (Orientation)
@property (nonatomic, readonly) BOOL isLandscape;
@end

@implementation UIDevice (Orientation)
- (BOOL) isLandscape
{
    return
        (self.orientation == UIDeviceOrientationLandscapeLeft) ||
        (self.orientation == UIDeviceOrientationLandscapeRight);
}
@end
