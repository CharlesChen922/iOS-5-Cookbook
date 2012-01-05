/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "Hello_WorldViewController.h"

@implementation Hello_WorldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// 從nib載入視圖後，進行其他設定
    field1.keyboardType = UIKeyboardTypeDecimalPad;
}

- (void)didRotateFromInterfaceOrientation:
(UIInterfaceOrientation) fromInterfaceOrientation
{
    // 移動華氏與攝氏標籤
    switch ([UIDevice currentDevice].orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            flabel.center = CGPointMake(61,114);
            clabel.center = CGPointMake(321, 114);
            ffield.center = CGPointMake(184, 116);
            cfield.center = CGPointMake(418, 116);
            break;
        }
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            flabel.center = CGPointMake(113, 121);
            clabel.center = CGPointMake(139, 160);
            ffield.center = CGPointMake(236, 123);
            cfield.center = CGPointMake(236, 162);
            break;
        }
        default:
            break;
    }
}


- (void) viewDidAppear:(BOOL)animated
{
    [self didRotateFromInterfaceOrientation:0];
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
