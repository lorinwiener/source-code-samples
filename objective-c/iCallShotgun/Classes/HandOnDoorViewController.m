//
//  HandOnDoorViewController.m
//  iCallShotgun
//
//  Created by Lorin Wiener on 12/8/09.
//  Copyright 2009 SharperMinds. All rights reserved.
//

#import "HandOnDoorViewController.h"
#import "BalkViewController.h"
#import "SitDownViewController.h"


@implementation HandOnDoorViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Hand On Door Rule";
	questionLabel.text = @"Was your hand on the car door?";
	ruleLabel.text = @"No one can call 'Shotgun' once your hand is on the car door.";	
}

-(IBAction)clickYes
{
	BalkViewController *balkViewController = [[BalkViewController alloc] initWithNibName:(NSString *)@"RulesViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:balkViewController animated:YES];
}

-(IBAction)clickNo
{
	SitDownViewController *sitDownViewController = [[SitDownViewController alloc] initWithNibName:(NSString *)@"RulesViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:sitDownViewController animated:YES];
}

@end