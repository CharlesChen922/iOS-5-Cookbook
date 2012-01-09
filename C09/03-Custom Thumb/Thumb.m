//
//  Thumb.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/22/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "Thumb.h"

// 在內文裡置中繪製文字
void centerText(CGContextRef context, NSString *fontname, float textsize, NSString *text, CGPoint point, UIColor *color)
{
    CGContextSaveGState(context);
    CGContextSelectFont(context, [fontname UTF8String], textsize, kCGEncodingMacRoman);
    
    // 取得文字寬度，但不會進行任何繪製
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowTextAtPoint(context, 0.0f, 0.0f, [text UTF8String], text.length);
    CGPoint endpoint = CGContextGetTextPosition(context);
    CGContextRestoreGState(context);
    
    // 向字型查詢高度。回傳的寬度資訊比較不可靠
    CGSize stringSize = [text sizeWithFont:[UIFont fontWithName:fontname size:textsize]];
    
    // 繪製文字
    [color setFill];
    CGContextSetShouldAntialias(context, true);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetTextMatrix (context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
    CGContextShowTextAtPoint(context, point.x - endpoint.x / 2.0f, point.y + stringSize.height / 4.0f, [text UTF8String], text.length); 
    CGContextRestoreGState(context);
}

// 以灰階深淺顏色建立大姆哥圖像
UIImage *thumbWithLevel (float aLevel)
{
    float INSET_AMT = 1.5f;
    CGRect baseRect = CGRectMake(0.0f, 0.0f, 40.0f, 100.0f);
    CGRect thumbRect = CGRectMake(0.0f, 40.0f, 40.0f, 20.0f);
    
    UIGraphicsBeginImageContext(baseRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填滿一塊矩形區域
    [[UIColor darkGrayColor] setFill];
    CGContextAddRect(context, CGRectInset(thumbRect, INSET_AMT, INSET_AMT));
    CGContextFillPath(context);
    
    // 大姆哥的外框
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 2.0f);    
    CGContextAddRect(context, CGRectInset(thumbRect, 2.0f * INSET_AMT, 2.0f * INSET_AMT));
    CGContextStrokePath(context);
    
    // 填滿一塊橢圓區域準備標示數值
    CGRect ellipseRect = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    [[UIColor colorWithWhite:aLevel alpha:1.0f] setFill];
    CGContextAddEllipseInRect(context, ellipseRect);
    CGContextFillPath(context);
    
    // 繪製數字
    NSString *numstring = [NSString stringWithFormat:@"%0.1f", aLevel];
    UIColor *textColor = (aLevel > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
    centerText(context, @"Georgia", 20.0f, numstring, CGPointMake(20.0f, 20.0f), textColor);
    
    // 數字外圍的圓框
    [[UIColor grayColor] setStroke];
    CGContextSetLineWidth(context, 3.0f);    
    CGContextAddEllipseInRect(context, CGRectInset(ellipseRect, 2.0f, 2.0f));
    CGContextStrokePath(context);
    
    // 建立並回傳圖像
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// 回傳基本的大姆哥圖像，不包含泡泡
UIImage *simpleThumb()
{
    float INSET_AMT = 1.5f;
    CGRect baseRect = CGRectMake(0.0f, 0.0f, 40.0f, 100.0f);
    CGRect thumbRect = CGRectMake(0.0f, 40.0f, 40.0f, 20.0f);
    
    UIGraphicsBeginImageContext(baseRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 為大姆哥填滿一塊矩形區域
    [[UIColor darkGrayColor] setFill];
    CGContextAddRect(context, CGRectInset(thumbRect, INSET_AMT, INSET_AMT));
    CGContextFillPath(context);
    
    // 大姆哥的外框
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 2.0f);    
    CGContextAddRect(context, CGRectInset(thumbRect, 2.0f * INSET_AMT, 2.0f * INSET_AMT));
    CGContextStrokePath(context);
    
    // 取得大姆哥
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}