//
//  Hello_WorldViewController.m
//  Hello World
//
//  Created by Erica Sadun on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Hello_WorldViewController.h"

@implementation Hello_WorldViewController
@synthesize popoverController;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    // 解除已存在的懸浮元件並釋放
    if (self.popoverController)
    {
        [self.popoverController dismissPopoverAnimated:NO];
        self.popoverController = nil;
    }
        
    // 保留懸浮元件，設定它的內容大小
    if ([segue.identifier isEqualToString:@"basic pop"]) 
    {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        UIPopoverController *thePopoverController = [popoverSegue popoverController];
        thePopoverController.contentViewController.contentSizeForViewInPopover = CGSizeMake(320.0f, 320.0f);        
        [thePopoverController setDelegate:self];
        self.popoverController = thePopoverController;
    }
}

// 解除時，釋放懸浮元件
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)thePopoverController {
    self.popoverController = nil;
}

// 先前步步指引的程式碼
- (IBAction)dismissModalController:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// 支援所有裝置擺設方向，自動旋轉
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    return YES;
}
@end
