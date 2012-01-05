//
//  Hello_WorldViewController.m
//  Hello World
//
//  Created by Erica Sadun on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Hello_WorldViewController.h"

@implementation Hello_WorldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 從nib載入視圖後，進行其他設定
    field1.keyboardType = UIKeyboardTypeDecimalPad;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction) convert: (id) sender
{
    float invalue = [[field1 text] floatValue];
    float outvalue = (invalue - 32.0f) * 5.0f / 9.0f;
    [field2 setText:[NSString stringWithFormat:@"%3.2f", outvalue]];
    [field1 resignFirstResponder];
}
@end
