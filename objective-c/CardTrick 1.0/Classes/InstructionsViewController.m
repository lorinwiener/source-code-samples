//
//  InstructionsViewController.m
//  CardTrick 1.2
//
//  Created by Lorin Wiener on 09/05/09.
//  Copyright 2008 SharperMinds. All rights reserved.
//

#import "InstructionsViewController.h"
#import "SecretViewController.h"


@implementation InstructionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {	
	UIImageView* backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
	UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"instructions" ofType:@"png"]];
	backgroundImageView.image = image;
	[self.view addSubview:backgroundImageView];
	
	UIButton* urlButton = [UIButton buttonWithType:UIButtonTypeCustom];		
	[urlButton initWithFrame:CGRectMake(5, 196, 15, 80)];	
	[urlButton setTitle:@"" forState: UIControlStateNormal];			
	[urlButton addTarget:self action:@selector(visitWebsite:) forControlEvents:UIControlEventTouchUpInside];
	UIImage * image2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"etrick_com_secret" ofType:@"png"]];
	[urlButton setBackgroundImage:image2 forState: UIControlStateNormal];	
	[self.view addSubview:urlButton];
	
	UIButton* nextButton = [UIButton buttonWithType:UIButtonTypeCustom];		
	[nextButton initWithFrame:CGRectMake(0, 431, 27, 32)];	
	[nextButton setTitle:@"" forState: UIControlStateNormal];			
	[nextButton addTarget:self action:@selector(goToSecret:) forControlEvents:UIControlEventTouchUpInside];
	UIImage * image3 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nextButton" ofType:@"png"]];
	[nextButton setBackgroundImage:image3 forState: UIControlStateNormal];	
	[self.view addSubview:nextButton];
}

-(IBAction)goToSecret:(id)sender{
	SecretViewController* viewController = [[SecretViewController alloc] initWithNibName:@"SecretViewController" bundle:nil];
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
