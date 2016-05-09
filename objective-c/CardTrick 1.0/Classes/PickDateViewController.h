//
//  PickDateViewController.h
//  CardTrick 1.2
//
//  Created by Lorin Wiener on 09/05/09.
//  Copyright 2008 SharperMinds. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PickDateViewController : UIViewController {
	UIDatePicker* datePicker;
	IBOutlet UIButton* enterButton;
}

@property (nonatomic, retain) UIButton *enterButton;

@end
