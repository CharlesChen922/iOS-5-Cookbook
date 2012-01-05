//
//  Hello_WorldViewController.h
//  Hello World
//
//  Created by Erica Sadun on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Hello_WorldViewController : UIViewController
{
    IBOutlet UITextField *field1;
    IBOutlet UITextField *field2;
	
	IBOutlet UILabel *flabel;
	IBOutlet UILabel *clabel;
    IBOutlet UITextField *ffield;
    IBOutlet UITextField *cfield;
}
- (IBAction)convert:(id)sender;
@end
