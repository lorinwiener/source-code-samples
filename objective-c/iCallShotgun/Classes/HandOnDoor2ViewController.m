//
//  HandOnDoor2ViewController.m
//  iCallShotgun
//
//  Created by Lorin Wiener on 12/8/09.
//  Copyright 2009 SharperMinds. All rights reserved.
//

#import "HandOnDoor2ViewController.h"
#import "Balk2ViewController.h"
#import "SitDown2ViewController.h"


@implementation HandOnDoor2ViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Hand On Door Rule";
	questionLabel.text = @"Was somone else's hand on the car door?";
	ruleLabel.text = @"No one can call 'Shotgun' once one's hand is on the car door.";
}

-(IBAction)clickYes
{
	Balk2ViewController *balk2ViewController = [[Balk2ViewController alloc] initWithNibName:(NSString *)@"RulesViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:balk2ViewController animated:YES];
}

-(IBAction)clickNo
{
	SitDown2ViewController *sitDown2ViewController = [[SitDown2ViewController alloc] initWithNibName:(NSString *)@"RulesViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:sitDown2ViewController animated:YES];
}

@end