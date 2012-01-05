//
//  Hello_WorldViewController.h
//  Hello World
//
//  Created by Erica Sadun on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// 實作懸浮元件控制器的委派協定
@interface Hello_WorldViewController : UIViewController <UIPopoverControllerDelegate>

// 前一份步步指引的程式碼
- (IBAction)dismissModalController:(id)sender;

// 保留懸浮元件
@property (strong) UIPopoverController *popoverController;
@end

