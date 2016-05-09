//
//  SecretViewController.m
//  CardTrick 1.2
//
//  Created by Lorin Wiener on 09/05/09.
//  Copyright 2008 SharperMinds. All rights reserved.
//

#import "SecretViewController.h"


@implementation SecretViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {	
	UIImageView* backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
	UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"secret_screen_background" ofType:@"png"]];
	backgroundImageView.image = image;
	[self.view addSubview:backgroundImageView];
	
	UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];		
	[backButton initWithFrame:CGRectMake(0, 431, 27, 32)];	
	[backButton setTitle:@"" forState: UIControlStateNormal];			
	[backButton addTarget:self action:@selector(backToMain:) forControlEvents:UIControlEventTouchUpInside];
	UIImage * image1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backtomainfromsecret" ofType:@"png"]];
	[backButton setBackgroundImage:image1 forState: UIControlStateNormal];	
	[self.view addSubview:backButton];
	
	UIButton* urlButton = [UIButton buttonWithType:UIButtonTypeCustom];		
	[urlButton initWithFrame:CGRectMake(5, 196, 15, 80)];	
	[urlButton setTitle:@"" forState: UIControlStateNormal];			
	[urlButton addTarget:self action:@selector(visitWebsite:) forControlEvents:UIControlEventTouchUpInside];
	UIImage * image2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"etrick_com_secret" ofType:@"png"]];
	[urlButton setBackgroundImage:image2 forState: UIControlStateNormal];	
	[self.view addSubview:urlButton];
}
 
-(IBAction)backToMain:(id)sender{
	[[[[self parentViewController] parentViewController] parentViewController] dismissModalViewControllerAnimated:NO];
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
