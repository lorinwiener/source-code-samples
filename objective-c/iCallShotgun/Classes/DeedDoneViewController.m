//
//  DeedDoneViewController.m
//  iCallShotgun
//
//  Created by Lorin Wiener on 12/8/09.
//  Copyright 2009 SharperMinds. All rights reserved.
//

#import "DeedDoneViewController.h"
#import "BeOutsideViewController.h"
#import "LoseViewController.h"


@implementation DeedDoneViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{	
    [super viewDidLoad];	
	self.title = @"Deed Done Rule";
	questionLabel.text = @"Was the deed done?";
	ruleLabel.text = @"The deed (i.e. visiting a friend) must be completed before calling 'Shotgun'.";
}

-(IBAction)clickYes
{
	BeOutsideViewController *beOutsideViewController = [[BeOutsideViewController alloc] initWithNibName:(NSString *)@"RulesViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:beOutsideViewController animated:YES];
}

-(IBAction)clickNo
{
	LoseViewController *loseViewController = [[LoseViewController alloc] initWithNibName:(NSString *)@"LoseViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:loseViewController animated:YES];
}


@end