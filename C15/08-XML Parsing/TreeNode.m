/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

//
//  TreeNode.m
//  Created by Erica Sadun on 4/6/09.
//

#import "TreeNode.h"

// 字串工具巨集
#define STRIP(X)	[X stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

@implementation TreeNode
@synthesize parent, children, key, leafvalue;

#pragma mark Create and Initialize TreeNodes
+ (TreeNode *) treeNode
{
    TreeNode *node = [[self alloc] init];
    node.children = [NSMutableArray array];
	return node;
}

#pragma mark TreeNode type routines
- (BOOL) isLeaf
{
	return (self.children.count == 0);
}

- (BOOL) hasLeafValue
{
	return (self.leafvalue != nil);
}

#pragma mark TreeNode data recovery routines
// 回傳含有子節點的鍵的陣列，不遞迴
- (NSArray *) keys
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children) [results addObject:node.key];
	return results;
}

// 回傳含有子節點的鍵的陣列，深度優先遞迴
- (NSArray *) allKeys
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children) 
	{
		[results addObject:node.key];
		[results addObjectsFromArray:node.allKeys];
	}
	return results;
}

- (NSArray *) uniqArray: (NSArray *) anArray
{
	NSMutableArray *array = [NSMutableArray array];
	for (id object in [anArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)])
		if (![[array lastObject] isEqualToString:object]) [array addObject:object];
	return array;
}

// 回傳排序後、子節點的鍵的陣列，陣列裡的鍵重複。不遞迴
- (NSArray *) uniqKeys
{
	return [self uniqArray:[self keys]];
}

// 回傳排序後、子節點的鍵的陣列，陣列裡的鍵重複。深度優先遞迴
- (NSArray *) uniqAllKeys
{
	return [self uniqArray:[self allKeys]];
}

// 若子節點是樹葉，收集起來，以陣列回傳，不遞迴
- (NSArray *) leaves
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children) if (node.leafvalue) [results addObject:node.leafvalue];
	return results;
}

// 若子節點是樹葉，收集起來，以陣列回傳，深度優先遞迴
- (NSArray *) allLeaves
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children) 
	{
		if (node.leafvalue) [results addObject:node.leafvalue];
		[results addObjectsFromArray:node.allLeaves];
	}
	return results;
}

#pragma mark TreeNode search and retrieve routines

// 回傳第一個與鍵配對成功的子節點，廣度優先遞迴
- (TreeNode *) objectForKey: (NSString *) aKey
{
	TreeNode *result = nil;
	for (TreeNode *node in self.children) 
		if ([node.key isEqualToString: aKey])
		{
			result = node;
			break;
		}
	if (result) return result;
	for (TreeNode *node in self.children)
	{
		result = [node objectForKey:aKey];
		if (result) break;
	}
	return result;
}

// 回傳與鍵配對成功的第一個樹葉，廣度優先遞迴
- (NSString *) leafForKey: (NSString *) aKey
{
	TreeNode *node = [self objectForKey:aKey];
	return node.leafvalue;
}

// 回傳所有與鍵配對成功的子節點，深度優先遞迴
- (NSMutableArray *) objectsForKey: (NSString *) aKey
{
	NSMutableArray *result = [NSMutableArray array];
	for (TreeNode *node in self.children) 
	{
		if ([node.key isEqualToString: aKey]) [result addObject:node];
		[result addObjectsFromArray:[node objectsForKey:aKey]];
	}
	return result;
}

// 回傳所有與鍵配對成功的樹葉，深度優先遞迴
- (NSMutableArray *) leavesForKey: (NSString *) aKey
{
	NSMutableArray *result = [NSMutableArray array];
	for (TreeNode *node in [self objectsForKey:aKey]) 
		if (node.leafvalue)
			[result addObject:node.leafvalue];
	return result;
}

// 根據鍵路徑，第一個配對成功的分支，回傳節點
- (TreeNode *) objectForKeys: (NSArray *) keys
{
	if ([keys count] == 0) return self;
	
	NSMutableArray *nextArray = [NSMutableArray arrayWithArray:keys];
	[nextArray removeObjectAtIndex:0];
	
	for (TreeNode *node in self.children)
	{
		if ([node.key isEqualToString:[keys objectAtIndex:0]])
			return [node objectForKeys:nextArray];
	}
	
	return nil;
}

// 根據鍵路徑，第一個配對成功的分支，回傳樹葉
- (NSString *) leafForKeys: (NSArray *) keys
{
	TreeNode *node = [self objectForKeys:keys];
	return node.leafvalue;
}

#pragma mark output utilities
// 印出樹狀結構
- (void) dumpAtIndent: (int) indent into:(NSMutableString *) outstring
{
	for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
	
	[outstring appendFormat:@"[%2d] Key: %@ ", indent, key];
	if (self.leafvalue) [outstring appendFormat:@"(%@)", STRIP(self.leafvalue)];
	[outstring appendString:@"\n"];
	
	for (TreeNode *node in self.children) [node dumpAtIndent:indent + 1 into: outstring];
}

- (NSString *) dump
{
	NSMutableString *outstring = [[NSMutableString alloc] init];
	[self dumpAtIndent:0 into:outstring];
	return outstring;
}

#pragma mark conversion utilities
// 若確定你是所有樹葉的父節點，轉成字典
- (NSMutableDictionary *) dictionaryForChildren
{
	NSMutableDictionary *results = [NSMutableDictionary dictionary];
	
	for (TreeNode *node in self.children)
		if (node.hasLeafValue) [results setObject:node.leafvalue forKey:node.key];
	
	return results;
}

#pragma mark invocation forwarding
// 方法轉送，讓節點運作方式如同陣列一樣
- (id)forwardingTargetForSelector:(SEL)sel 
{ 
	if ([self.children respondsToSelector:sel]) return self.children; 
	return nil;
}

// 擴充方法選擇子
- (BOOL)respondsToSelector:(SEL)aSelector
{
	if ( [super respondsToSelector:aSelector] )	return YES;
	if ([self.children respondsToSelector:aSelector]) return YES;
	return NO;
}

// 允許子節點以NSArray的姿態出現
- (BOOL)isKindOfClass:(Class)aClass
{
	if (aClass == [TreeNode class]) return YES;
	if ([super isKindOfClass:aClass]) return YES;
	if ([self.children isKindOfClass:aClass]) return YES;
	
	return NO;
}

#pragma mark cleanup
- (void) dealloc
{
	self.parent = nil;
	self.children = nil;
	self.key = nil;
	self.leafvalue = nil;
}
@end