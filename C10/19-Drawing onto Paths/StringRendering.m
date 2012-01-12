//
//  StringRendering.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/29/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "StringRendering.h"
#import "StringHelper.h"

@implementation StringRendering
@synthesize string, view, inset;
+ (id) rendererForView: (UIView *) aView string: (NSAttributedString *) aString
{
    StringRendering *renderer = [[self alloc] init];
    renderer.view = aView;
    renderer.string = aString;
    return renderer;
}

// 準備翻轉過的內文
- (void) prepareContextForCoreText
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, view.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0); // 翻轉內文
}

// 因為內文已經翻轉，隨之調整用來繪製的矩形
- (CGRect) adjustedRect: (CGRect) rect
{
    CGRect newRect = rect;
    CGFloat newYOrigin = view.frame.size.height - (rect.size.height + rect.origin.y);
    newRect.origin.y = newYOrigin;
    return newRect;
}

// 在矩形裡加入文字
- (void) drawInRect: (CGRect) theRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect insetRect = CGRectInset(theRect, inset, inset);
	CGRect rect = [self adjustedRect: insetRect];
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
    
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), path, NULL);
	
	CTFrameDraw(theFrame, context);
	
	CFRelease(framesetter);
	CFRelease(theFrame);
	CFRelease(path);
}

// 在路徑裡繪製
- (void) drawInPath: (CGMutablePathRef) path
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), path, NULL);
	
	CTFrameDraw(theFrame, context);
	
	CFRelease(framesetter);
	CFRelease(theFrame);
	CFRelease(path);	

}

// 回傳兩點距離
float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

- (void) drawOnPoints: (NSArray *) points
{
	int pointCount = points.count;
	if (pointCount < 2) return;
    
    // 計算
    
    // 計算路徑長度
	float totalPointLength = 0.0f;
	for (int i = 1; i < pointCount; i++)
		totalPointLength += distance([[points objectAtIndex:i] CGPointValue], [[points objectAtIndex:i-1] CGPointValue]);
	
	// 建立排版線，取得長度
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	if (!line) return;
	double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	
	// 取得字符流
	CFArrayRef runArray = CTLineGetGlyphRuns(line);
	
	// 計算項目個數
	int glyphCount = 0; //  經過的字符個數
	float runningWidth; //  記錄字符流的寬度
	int glyphNum = 0;   //  目前的字符
	for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) 
	{
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) 
		{
			runningWidth += CTRunGetTypographicBounds(run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
			if (!glyphNum && (runningWidth > totalPointLength))
				glyphNum = glyphCount;
			glyphCount++;
		}
	}
    
    // 利用總長度，計算每一點座標的百分比例
	NSMutableArray *pointPercentArray = [NSMutableArray array];
	[pointPercentArray addObject:[NSNumber numberWithFloat:0.0f]];
	float distanceTravelled = 0.0f;
	for (int i = 1; i < pointCount; i++)
	{
		distanceTravelled += distance([[points objectAtIndex:i] CGPointValue], [[points objectAtIndex:i-1] CGPointValue]);
		[pointPercentArray addObject:[NSNumber numberWithFloat:(distanceTravelled / totalPointLength)]];
	}
	
	// 加入最後的項目
	[pointPercentArray addObject:[NSNumber numberWithFloat:2.0f]];
    
    
    // 準備繪製
    
    NSRange subrange = {0, glyphNum};
    NSAttributedString *newString = [string attributedSubstringFromRange:subrange];
    
	// 為新字串重新建立線與字符流陣列
	if (glyphNum)
	{
		CFRelease(line);
        
		line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)newString);
		if (!line) {NSLog(@"Error re-creating line"); return;}
		
		lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
		runArray = CTLineGetGlyphRuns(line);
	}
 
	// 記錄字符已經走多遠了
    // 才能計算在點路徑上的百分比例
	float glyphDistance = 0.0f;
		
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // 設定初始位置
    CGPoint textPosition = CGPointMake(0.0f, 0.0f);
	CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) 
	{
		// 取得字符流
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		
        // 取得字型與顏色
		CFDictionaryRef attributes = CTRunGetAttributes(run);
		CTFontRef runFont = CFDictionaryGetValue(attributes, kCTFontAttributeName);
		CGColorRef fontColor = (CGColorRef) CFDictionaryGetValue(attributes, kCTForegroundColorAttributeName);
		CFShow(attributes);
		if (fontColor) [[UIColor colorWithCGColor:fontColor] set];
		
		// 在字符流裡迭代每一個字符
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) 
		{
			// 計算已經經過的百分比
			float glyphWidth = CTRunGetTypographicBounds(run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);			
			float percentConsumed = glyphDistance / lineLength;
            
			// 在路徑裡找出相對應的一對點座標
			CFIndex index = 1;
			while ((index < pointPercentArray.count) && 
				   (percentConsumed > [[pointPercentArray objectAtIndex:index] floatValue]))
				index++;
			
			// 沒資料時可別試著繪製啊。這不該發生。
			if (index > (points.count - 1)) continue;
			
			// 計算兩點之間的中間點
			CGPoint point1 = [[points objectAtIndex:index - 1] CGPointValue];
			CGPoint point2 = [[points objectAtIndex:index] CGPointValue];
            
			float percent1 = [[pointPercentArray objectAtIndex:index - 1] floatValue];
			float percent2 = [[pointPercentArray objectAtIndex:index] floatValue];
			float percentOffset = (percentConsumed - percent1) / (percent2 - percent1);
            
			float dx = point2.x - point1.x;
			float dy = point2.y - point1.y;
			
			CGPoint targetPoint = CGPointMake(point1.x + (percentOffset * dx), (point1.y + percentOffset * dy));
			targetPoint.y = view.bounds.size.height - targetPoint.y;
            
			// 設定內文的x與y位移
			CGContextTranslateCTM(context, targetPoint.x, targetPoint.y);
			CGPoint positionForThisGlyph = CGPointMake(textPosition.x, textPosition.y);
			
			// 旋轉內文
			float angle = -atan(dy / dx);
			if (dx < 0) angle += M_PI; // going left, update the angle
			CGContextRotateCTM(context, angle);
			
			// 套用文字矩陣幾何轉換
			textPosition.x -= glyphWidth;
			CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
			textMatrix.tx = positionForThisGlyph.x;
			textMatrix.ty = positionForThisGlyph.y;
			CGContextSetTextMatrix(context, textMatrix);
			
			// 繪製字符
			CGGlyph glyph;
			CGPoint position;
			CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
			CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
			CTRunGetGlyphs(run, glyphRange, &glyph);
			CTRunGetPositions(run, glyphRange, &position);
			CGContextSetFont(context, cgFont);
			CGContextSetFontSize(context, CTFontGetSize(runFont));
			CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
			
			CFRelease(cgFont);
			
			// 重置內文的幾何轉換
			CGContextRotateCTM(context, -angle);
			CGContextTranslateCTM(context, -targetPoint.x, -targetPoint.y);
			
			glyphDistance += glyphWidth;
		}
	}
	
	CFRelease(line);
	CGContextRestoreGState(context);
}

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

// 從貝茲曲線上取得點座標
void _getPointsFromBezier(void *info, const CGPathElement *element) 
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;    
    
    // 取得路徑上的元素種類與它的點座標
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // 如果可用的話（根據種類）加入點座標
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }    
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

NSArray *_pointsFromBezierPath(UIBezierPath *bpath)
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(bpath.CGPath, (__bridge void *)points, _getPointsFromBezier);
    return points;
}

- (void) drawOnBezierPath: (UIBezierPath *) path
{
    NSArray *points = _pointsFromBezierPath(path);
    [self drawOnPoints:points];
}

@end
