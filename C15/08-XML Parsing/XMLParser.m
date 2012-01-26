/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

//
//  XMLParser.m
//  Created by Erica Sadun on 4/6/09.
//

#import "XMLParser.h"

@implementation XMLParser
static XMLParser *sharedInstance = nil;

// 單件設計模式，任何時候只有一個解析器實體
+(XMLParser *) sharedInstance 
{
    if(!sharedInstance)
		sharedInstance = [[self alloc] init];
    return sharedInstance;
}

// 解析器回傳樹的根節點，你必須往下一個節點，
// 才是真正的結果。
- (TreeNode *) parse: (NSXMLParser *) parser
{
	stack = [NSMutableArray array];
	TreeNode *root = [TreeNode treeNode];
	[stack addObject:root];

	[parser setDelegate:self];
	[parser parse];

	// 往下找尋真的根
	TreeNode *realroot = [[root children] lastObject];

    // 移除任何連結
	root.children = nil;
	root.leafvalue = nil;
	root.key = nil;
	realroot.parent = nil;
	
    // 回傳真的根
	return realroot;
}

- (TreeNode *)parseXMLFromURL: (NSURL *) url
{	
	TreeNode *results = nil;
    @autoreleasepool {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        results = [self parse:parser];
    }
	return results;
}

- (TreeNode *)parseXMLFromData: (NSData *) data
{	
	TreeNode *results = nil;
    @autoreleasepool {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        results = [self parse:parser];
    }
    return results;
}

// 往下找到新元素
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) elementName = qName;
	
	TreeNode *leaf = [TreeNode treeNode];
	leaf.parent = [stack lastObject];
	[(NSMutableArray *)[[stack lastObject] children] addObject:leaf];
	
	leaf.key = [NSString stringWithString:elementName];
	leaf.leafvalue = nil;
	leaf.children = [NSMutableArray array];
	
	[stack addObject:leaf];
}

// 元素結束時，疊出
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[stack removeLastObject];
}

// 抵達樹葉
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (![[stack lastObject] leafvalue])
	{
		[[stack lastObject] setLeafvalue:[NSString stringWithString:string]];
		return;
	}
	[[stack lastObject] setLeafvalue:[NSString stringWithFormat:@"%@%@", [[stack lastObject] leafvalue], string]];
}

@end



