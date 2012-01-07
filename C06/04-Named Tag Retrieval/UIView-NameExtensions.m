/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "UIView-NameExtensions.h"

@interface ViewIndexer : NSObject {
	NSMutableDictionary *tagdict;
	NSInteger count;
}
@end

@implementation ViewIndexer

#pragma mark sharedInstance
static ViewIndexer *sharedInstance = nil;

+(ViewIndexer *) sharedInstance {
    if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (id) init
{
	if (!(self = [super init])) return self;
	tagdict = [NSMutableDictionary dictionary];
	count = 10000;
	return self;
}

#pragma mark registration
// 取得新數字並增加計數值
- (NSInteger) pullNumber
{
	return count++;
}

// 檢查名稱是否已經存在於字典裡
- (BOOL) nameExists: (NSString *) aName
{
	return [tagdict objectForKey:aName] != nil;
}

// 抓出第一個與標號配對成功的名稱
- (NSString *) nameForTag: (NSInteger) aTag
{
	NSNumber *tag = [NSNumber numberWithInt:aTag];
	NSArray *names = [tagdict allKeysForObject:tag];
	if (!names) return nil;
	if ([names count] == 0) return nil;
	return [names objectAtIndex:0];
}

// 回傳已註冊名稱的標號，若無回傳0
- (NSInteger) tagForName: (NSString *)aName
{
	NSNumber *tag = [tagdict objectForKey:aName];
	if (!tag) return 0;
	return [tag intValue];
}

// 取消註冊，標號設回0
- (BOOL) unregisterName: (NSString *) aName forView: (UIView *) aView
{
	NSNumber *tag = [tagdict objectForKey:aName];
	
	// 沒找到標號
	if (!tag) return NO;
	
	// 標號無法與已註冊名稱配對成功
	if (aView.tag != [tag intValue]) return NO;
	
	aView.tag = 0;
	[tagdict removeObjectForKey:aName];
	return YES;
}

// 註冊新名稱，名稱不能再次註冊。（請先取消註冊。）
// 如果視圖已經註冊過，它會被取消註冊，然後重新註冊。
- (NSInteger) registerName:(NSString *)aName forView: (UIView *) aView
{
	// 你不能再次註冊已經存在的名稱
	if ([[ViewIndexer sharedInstance] nameExists:aName]) return 0;
	
	// 檢查視圖否已經有名稱了，若是，取消註冊。
	NSString *currentName = [self nameForTag:aView.tag];
	if (currentName) [self unregisterName:currentName forView:aView];
	
	// 若有標號，進行註冊。若aView.tag為0，先抓出一個新標號。
	if (!aView.tag) aView.tag = [[ViewIndexer sharedInstance] pullNumber];
	[tagdict setObject:[NSNumber numberWithInt:aView.tag] forKey:aName];
	return aView.tag;
}
@end

#pragma mark - Associations
enum {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};


typedef uintptr_t objc_AssociationPolicy;
id objc_getAssociatedObject(id object, void *key);
void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy);
void objc_removeAssociatedObjects(id object);


static const char *NametagKey = "Nametag Key";

@implementation UIView (NameExtensions)
#pragma mark Associations
- (id) nametag 
{
    return objc_getAssociatedObject(self, (void *) NametagKey);
}

- (void)setNametag:(NSString *) theNametag 
{
    objc_setAssociatedObject(self, (void *) NametagKey, theNametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *) viewWithNametag: (NSString *) aName
{
    if (!aName) return nil;
    
    // 這是正確的視圖嗎？
    if ([self.nametag isEqualToString:aName])
        return self;
    
    // 遞迴式、深度優先
    for (UIView *subview in self.subviews) 
    {
        UIView *resultView = [subview viewNamed:aName];
        if (resultView) return resultView;
    }
    
    // 沒找到
    return nil;
}


#pragma mark Registration
- (NSInteger) registerName: (NSString *) aName
{
	return [[ViewIndexer sharedInstance] registerName:aName forView:self];
}

- (BOOL) unregisterName: (NSString *) aName
{
	return [[ViewIndexer sharedInstance] unregisterName:aName forView:self];
}

#pragma mark Typed Name Retrieval
- (UIView *) viewNamed: (NSString *) aName
{
    if (!aName) return nil;
    
    // 若要使用註冊名稱的作法，請拿掉註解。
    /*
	NSInteger tag = [[ViewIndexer sharedInstance] tagForName:aName];
	return [self viewWithTag:tag];
     */
    
    // 若要使用關聯式名稱的作法，請拿掉註解。
    return [self viewWithNametag:aName];
}

- (UIAlertView *) alertViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIAlertView class]])
        return (UIAlertView *)aView;
    return nil;
}

- (UIActionSheet *) actionSheetNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIActionSheet class]])
        return (UIActionSheet *)aView;
    return nil;
}

- (UITableView *) tableViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITableView class]])
        return (UITableView *)aView;
    return nil;
}

- (UITableViewCell *) tableViewCellNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITableViewCell class]])
        return (UITableViewCell *)aView;
    return nil;
}

- (UIImageView *) imageViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIImageView class]])
        return (UIImageView *)aView;
    return nil;
}

- (UIWebView *) webViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIWebView class]])
        return (UIWebView *)aView;
    return nil;
}

- (UITextView *) textViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITextView class]])
        return (UITextView *)aView;
    return nil;
}

- (UIScrollView *) scrollViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIScrollView class]])
        return (UIScrollView *)aView;
    return nil;
}

- (UIPickerView *) pickerViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIPickerView class]])
        return (UIPickerView *)aView;
    return nil;
}

- (UIDatePicker *) datePickerNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIDatePicker class]])
        return (UIDatePicker *)aView;
    return nil;
}

- (UISegmentedControl *) segmentedControlNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISegmentedControl class]])
        return (UISegmentedControl *)aView;
    return nil;
}

- (UILabel *) labelNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UILabel class]])
        return (UILabel *)aView;
    return nil;
}

- (UIButton *) buttonNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIButton class]])
        return (UIButton *)aView;
    return nil;
}

- (UITextField *) textFieldNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITextField class]])
        return (UITextField *)aView;
    return nil;
}

- (UISwitch *) switchNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISwitch class]])
        return (UISwitch *)aView;
    return nil;
}

- (UISlider *) sliderNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISlider class]])
        return (UISlider *)aView;
    return nil;
}

- (UIProgressView *) progressViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIProgressView class]])
        return (UIProgressView *)aView;
    return nil;
}

- (UIActivityIndicatorView *) activityIndicatorViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIAlertView class]])
        return (UIActivityIndicatorView *)aView;
    return nil;
}

- (UIPageControl *) pageControlNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIPageControl class]])
        return (UIPageControl *)aView;
    return nil;
}

- (UIWindow *) windowNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIWindow class]])
        return (UIWindow *)aView;
    return nil;
}

- (UISearchBar *) searchBarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISearchBar class]])
        return (UISearchBar *)aView;
    return nil;
}

- (UINavigationBar *) navigationBarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UINavigationBar class]])
        return (UINavigationBar *)aView;
    return nil;
}

- (UIToolbar *) toolbarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIToolbar class]])
        return (UIToolbar *)aView;
    return nil;
}

- (UITabBar *) tabBarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITabBar class]])
        return (UITabBar *)aView;
    return nil;
}

- (UIStepper *) stepperNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIStepper class]])
        return (UIStepper *)aView;
    return nil;
}
@end