//
//  BalkViewController.m
//  iCallShotgun
//
//  Created by Lorin Wiener on 12/8/09.
//  Copyright 2009 SharperMinds. All rights reserved.
//

#import "BalkViewController.h"
#import "WinViewController.h"
#import "LoseViewController.h"


@implementation BalkViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Balk Rule";
	questionLabel.text = @"Did the Shotgun door remain locked?";
	ruleLabel.text = @"Anyone else can call Shotgun if you lift the handle too early and the door remains locked.";
}

-(IBAction)clickYes
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