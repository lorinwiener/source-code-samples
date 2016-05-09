//
//  CardTrickAppDelegate.m
//  CardTrick 1.2
//
//  Created by Lorin Wiener on 09/05/09.
//  Copyright 2008 SharperMinds. All rights reserved.
//

#import "CardTrickViewController.h"
#import "PickDateViewController.h"
#import "SelectCardViewController.h"

@implementation CardTrickViewController

 //Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
	UIButton* urlButton = [UIButton buttonWithType:UIButtonTypeCustom];		
	[urlButton initWithFrame:CGRectMake(116, 453, 80, 20)];	
	[urlButton setTitle:@"" forState: UIControlStateNormal];			
	[urlButton addTarget:self action:@selector(visitWebsite:) forControlEvents:UIControlEventTouchUpInside];
	UIImage * image1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"etrick_com" ofType:@"png"]];
	[urlButton setBackgroundImage:image1 forState: UIControlStateNormal];	
	[self.view addSubview:urlButton];
	infoButton.frame = CGRectMake(257, 394, 86, 86);	
	[super viewDidLoad];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{	
	// Avoid missing touching infoButton
	UITouch* touch = [touches anyObject];
	if (![touch.view isEqual:infoButton] ) {
		SelectCardViewController* viewController = [[SelectCardViewController alloc] initWithNibName:@"SelectCardViewController" bundle:nil];
		[self presentModalViewController:viewController animated:NO	];	
	}
	[super touchesBegan:touches withEvent:event];		
}

-(IBAction)infoTouched:(id)sender{
	PickDateViewController* viewController = [[PickDateViewController alloc] initWithNibName:@"PickDateViewController" bundle:nil];
	[self presentModalViewController:viewController animated:NO	];
}

-(IBAction)visitWebsite:(id)sender{
	NSString* visitWebsiteURL = @"http://www.e-tricks.com";	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:visitWebsiteURL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[super dealloc];
}

@end
