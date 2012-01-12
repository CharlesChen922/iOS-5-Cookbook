/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "MarkupHelper.h"
#import "StringHelper.h"

#define BASE_TEXT_SIZE	24.0f
#define STRMATCH(STRING1, STRING2) ([[STRING1 uppercaseString] rangeOfString:[STRING2 uppercaseString]].location != NSNotFound)

@implementation MarkupHelper
// 語彙掃描，類似HTML語法，建立標記樣式字串
+ (NSAttributedString *) stringFromMarkup: (NSString *) inputString
{
    NSString *aString = [inputString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
	// 準備掃描
	NSScanner *scanner = [NSScanner scannerWithString:aString];
	[scanner setCharactersToBeSkipped:[NSCharacterSet newlineCharacterSet]];
	NSCharacterSet *startSet = [NSCharacterSet characterSetWithCharactersInString:@"<"];
	NSCharacterSet *endSet = [NSCharacterSet characterSetWithCharactersInString:@">"];
	
	// 初始化StringHelper
	StringHelper *stringHelper = [StringHelper buildHelper];
	CGFloat fontSize = BASE_TEXT_SIZE;
    
	// 初始化標頭（header）、粗體、斜體
	int hlevel = 0;
	BOOL bold = NO, emph = NO;
	
	NSUInteger loc = 0;
	while (loc < aString.length)
	{
		NSString *contentText = nil; // 掃描直到標籤
		[scanner scanUpToCharactersFromSet:startSet intoString:&contentText];
		
		// 在此處理內容文字（無標籤）
		if (contentText)
		{
			// 下一個位置往前推進
			scanner.scanLocation = (loc += contentText.length + 1);
            
			// 為內容設定字型
			NSString *fontName = @"Futura-Medium";
			if (hlevel == 0)
			{
				//if (bold && emph) fontName = @"Futura-Medium";
				if (bold) fontName = @"Futura-CondensedExtraBold";
				else if (emph) fontName = @"Futura-MediumItalic";
			}
			
			stringHelper.fontName = fontName;
			stringHelper.fontSize = fontSize;
			[stringHelper appendFormat:contentText];
		}
        
		// 掃描標籤
		NSString *baseTag = nil; 
		[scanner scanUpToCharactersFromSet:endSet intoString:&baseTag];
		if (!baseTag)
		{
			NSLog(@"Unexpected error encountered while scanning! Bailing. Sorry.");
			return stringHelper.string;
		}
		
		// 下一個位置往前推進
		scanner.scanLocation = (loc += baseTag.length + 1);
		
		// 還原標準標籤格式
		NSString *tagText = [baseTag stringByAppendingString:@">"];
		if (![tagText hasPrefix:@"<"]) 
			tagText = [@"<" stringByAppendingString:tagText];
		
		// -- 處理標籤 --
		
		// 標頭（header）標籤
		if (STRMATCH(tagText, @"</h")) // 結束標頭
		{
			hlevel = 0;
			[stringHelper appendFormat:@"\n"];
			fontSize = BASE_TEXT_SIZE;
		}
		else if (STRMATCH(tagText, @"<h1>")) hlevel = 1;
		else if (STRMATCH(tagText, @"<h2>")) hlevel = 2;
		else if (STRMATCH(tagText, @"<h3>")) hlevel = 3;
		else hlevel = 0;
		if (hlevel)
			fontSize = BASE_TEXT_SIZE + (8.0f - hlevel) * 2.0f;
		
		// 粗體與斜體標籤
		if (STRMATCH(tagText, @"</i>"))			emph = NO;
		else if (STRMATCH(tagText, @"<i>"))		emph = YES;
		else if (STRMATCH(tagText, @"</b>"))	bold = NO;
		else if (STRMATCH(tagText, @"<b>"))		bold = YES;
		
		// 置中標籤
		if (STRMATCH(tagText, @"</center>"))
			stringHelper.alignment = @"natural";
		else if (STRMATCH(tagText, @"<center>"))
			stringHelper.alignment = @"center";
		
		// 客製（非HTML）標籤，範例：顏色與大小
		
		if (STRMATCH(tagText, @"<color red>"))
			stringHelper.foregroundColor = [UIColor redColor];
		if (STRMATCH(tagText, @"<color green>"))
			stringHelper.foregroundColor = [UIColor greenColor];
		if (STRMATCH(tagText, @"<color blue>"))
			stringHelper.foregroundColor = [UIColor blueColor];
		else if (STRMATCH(tagText, @"</color")) // match partial
			stringHelper.foregroundColor = [UIColor blackColor];
		
		if (STRMATCH(tagText, @"<size")) // 部分配對
		{
			// 掃描新字型大小的數值
			NSScanner *newScanner = [NSScanner scannerWithString:tagText];
			NSCharacterSet *cs = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
			[newScanner setCharactersToBeSkipped:cs];
			[newScanner scanFloat:&fontSize];
		}
		else if (STRMATCH(tagText, @"</size>"))
			fontSize = BASE_TEXT_SIZE;
		
        
		// 段落與換行標籤
		if (STRMATCH(tagText, @"<br")) // 與所有變種配對
			[stringHelper appendFormat:@"\n"];
		else if (STRMATCH(tagText, @"</p>"))
			[stringHelper appendFormat:@"\n\n"];
		else if (STRMATCH(tagText, @"<p>")) // 預設對齊方式
			stringHelper.alignment = @"natural";
	}
    
    return stringHelper.string;
}

@end
