/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ObjectCache.h"

@implementation ObjectCache
@synthesize myCache, allocationSize;

// 回傳新快取
+ (ObjectCache *) cache
{
	return [[ObjectCache alloc] init];
}

// 建立某大小的NSData，假裝有載入物件
- (id) loadObjectNamed: (NSString *) someKey
{
    if (!allocationSize)
        allocationSize = 1024 * 1024;

    char *foo = malloc(allocationSize);
    NSData *data = [NSData dataWithBytes:foo length:allocationSize];
    free(foo);
    return data;
}

// 當找不到某物件時，載入它
- (id) retrieveObjectNamed: (NSString *) someKey
{
    if (!myCache) 
        self.myCache = [NSMutableDictionary dictionary];
	id object = [myCache objectForKey:someKey];
	if (!object) 
	{
		if ((object = [self loadObjectNamed:someKey]))
            [myCache setObject:object forKey:someKey];
	}
	return object;
}

// 記憶體低下時清理快取
- (void) respondToMemoryWarning
{
	[myCache removeAllObjects];
}
@end
