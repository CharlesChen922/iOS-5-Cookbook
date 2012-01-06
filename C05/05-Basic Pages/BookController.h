//
//  BookController.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/5/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 用來記錄最後閱讀的頁面
#define DEFAULTS_BOOKPAGE   @"BookControllerMostRecentPage"

// 定義自訂的委派協定，供此包裹類別使用
@protocol BookControllerDelegate <NSObject>
- (id) viewControllerForPage: (int) pageNumber;
@optional
- (void) bookControllerDidTurnToPage: (NSNumber *) pageNumber;
@end

// 包裹著頁面視圖控制器的書本控制器
@interface BookController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
+ (id) bookWithDelegate: (id) theDelegate;
+ (id) rotatableViewController;
- (void) moveToPage: (uint) requestedPage;
- (int) currentPage;

@property (nonatomic, weak) id <BookControllerDelegate> bookDelegate;
@property (nonatomic, assign) uint pageNumber;
@end