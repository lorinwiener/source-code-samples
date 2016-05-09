//
//  Balk2ViewController.m
//  iCallShotgun
//
//  Created by Lorin Wiener on 12/8/09.
//  Copyright 2009 SharperMinds. All rights reserved.
//

#import "Balk2ViewController.h"
#import "WinViewController.h"
#import "LoseViewController.h"


@implementation Balk2ViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Balk Rule";
	questionLabel.text = @"Did the door remain locked?";
	ruleLabel.text = @"Anyone else can call Shotgun if one lift's the handle too early and the door remains locked.";
}

-(IBAction)clickYes\
{
	LoseViewController *loseViewController = [[LoseViewController alloc] initWithNibName:(NSString *)@"LoseViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:loseViewController animated:YES];
}

-(IBAction)clickNo
{
	WinViewController *winViewController = [[WinViewController alloc] initWithNibName:(NSString *)@"WinViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:winViewController animated:YES];
}
@end