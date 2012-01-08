/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

/*
 
 HOME鍵      相機     輸出    無鏡射            鏡射             擺設方向
 Bottom      Front   Right   Left Mirrored    Right            Portrait
 Right       Front   Down    Down Mirrored    Down             LandscapeLeft
 Top         Front   Left    Right Mirrored   Left             PortraitUpsideDown
 Left        Front   Up      Up Mirrored      Up               LandscapeRight

 Bottom      Back    Right   Right            Left Mirrored    Portrait
 Right       Back    Up      Up               Up Mirrored      LandscapeLeft
 Top         Back    Left    Left             Right Mirrored   PortraitUpsideDown
 Left        Back    Down    Down             Down Mirrored    LandscapeRight
 
 可用的擺設方向：EXIF 與 UIImageOrientation
 
 topleft toprt   botrt  botleft   leftop      righttop     rightbot   leftbot
 EXIF 1    2       3      4         5            6           7          8
 
 XXXXXX  XXXXXX      XX  XX      XXXXXXXXXX  XX                  XX  XXXXXXXXXX
 XX          XX      XX  XX      XX  XX      XX  XX          XX  XX      XX  XX
 XXXX      XXXX    XXXX  XXXX    XX          XXXXXXXXXX  XXXXXXXXXX          XX
 XX          XX      XX  XX
 XX          XX  XXXXXX  XXXXXX
 
 UI 0      4       1      5         6            2           7           3       
    up    upmirror down  downmir leftmir      left         rightmir    right
 
 
 
 擺設方向的對應關係：
 
 {1, 3, 6, 8, 2, 4, 5, 7};  EXIF
 {0  1  2  3  4  5  6  7}   UIIMG
 
 {1  2  3  4  5  6  7  8}   EXIF
 {0, 4, 1, 5, 6, 2, 7, 3};  UIIMG

 */

// EXIF擺設方向（EXIF ORIENTATIONS）
typedef enum {
    kTopLeft			= 1, // UIImageOrientationUp,           (0,0) at top left
    kTopRight           = 2, // UIImageOrientationUpMirrored,   (0,0) at top right
    kBottomRight        = 3, // UIImageOrientationDown          (0,0) at bottom right
    kBottomLeft         = 4, // UIImageOrientationDownMirrored  (0,0) at bottom left
    kLeftTop            = 5, // UIImageOrientationLeftMirrored  (0,0) at left top
    kRightTop           = 6, // UIImageOrientationLeft          (0,0) at right top
    kRightBottom        = 7, // UIImageOrientationRightMirrored (0,0) at right bottom
    kLeftBottom         = 8  // UIImageOrientationRight         (0,0) at left bottom
} ExifOrientation;

/*
 
 UIImage擺設方向（UIIMAGE ORIENTATIONS）
 
 typedef enum {
 UIImageOrientationUp =            0, // 旋轉0度 exif 1
 UIImageOrientationDown =          1, // 旋轉180度 exif 3
 UIImageOrientationLeft =          2, // 逆時鐘旋轉90度 exif 6
 UIImageOrientationRight =         3, // 順時鐘旋轉90度 exif 8
 UIImageOrientationUpMirrored =    4, // 水平翻轉 exif 2
 UIImageOrientationDownMirrored =  5, // 水平翻轉 exif 4
 UIImageOrientationLeftMirrored =  6, // 重直翻轉 exif 5
 UIImageOrientationRightMirrored = 7, // 垂直翻轉 exif 7
 } UIImageOrientation;
 */

/*
 
 裝置擺設方向（DEVICE ORIENTATIONS）
 
 UIDeviceOrientationUnknown
     無法判別裝置擺設方向
 UIDeviceOrientationPortrait
     直擺，Home鍵在下，裝置豎起來
 UIDeviceOrientationPortraitUpsideDown
     直擺，上下顛倒，Home鍵在上，裝置豎起來
 UIDeviceOrientationLandscapeLeft
     橫擺，Home健在右，裝置豎起來
 UIDeviceOrientationLandscapeRight
     橫擺，Home健在左，裝置豎起來
 UIDeviceOrientationFaceUp
     裝置與地面呈平行，螢幕面朝上（天空）
 UIDeviceOrientationFaceDown
     裝置與地面呈平行，螢幕面朝下（地面）
 */

// 工具函式

NSString *imageOrientationNameFromOrientation(UIImageOrientation orientation);
NSString *imageOrientationName(UIImage *anImage);
NSString *exifOrientationNameFromOrientation(uint orientation);
NSString *deviceOrientationName(UIDeviceOrientation orientation);
NSString *currentDeviceOrientationName();

BOOL deviceIsLandscape();
BOOL deviceIsPortrait();

uint exifOrientationFromUIOrientation(UIImageOrientation uiorientation);
UIImageOrientation imageOrientationFromEXIFOrientation(uint exiforientation);

UIImageOrientation currentImageOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip);
uint currentEXIFOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip);

// 有個很嚴重的bug，直擺 ∕ 後方相機時，無法正確辨認原生EXIF的資料
// 這個函式解決了這個問題
// 但是，之後，你必須隨之調整位置方向，唉。
uint detectorEXIF(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip);
