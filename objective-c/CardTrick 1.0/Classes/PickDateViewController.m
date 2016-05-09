//
//  PickDateViewController.m
//  CardTrick 1.2
//
//  Created by Lorin Wiener on 09/05/09.
//  Copyright 2008 SharperMinds. All rights reserved.
//

#import "PickDateViewController.h"
#import "InstructionsViewController.h"


@implementation PickDateViewController

@synthesize enterButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
	UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];		
	[backButton initWithFrame:CGRectMake(265, 415, 102, 97)];	
	[backButton setTitle:@"" forState: UIControlStateNormal];
	[backButton addTarget:self action:@selector(backToMain:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 159, 320, 216)];
	datePicker.datePickerMode = UIDatePickerModeDate;	
	[self.view addSubview:datePicker];
	UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [enterButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [enterButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setMonth:2]; 
	[components setDay:23]; 
	[components setYear:1873];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *initDate = [gregorian dateFromComponents:components];
	[datePicker setDate:initDate];	
}
  
-(IBAction)backToMain:(id)sender{
	[[self parentViewController] dismissModalViewControllerAnimated:NO];
}

-(IBAction)dateEntered:(id)sender{
	NSCalendar* cal = [NSCalendar currentCalendar];
	unsigned unitFlags =  NSYearCalendarUnit |  NSMonthCalendarUnit|NSDayCalendarUnit;
	NSDate *date = datePicker.date;
	NSDateComponents *comps = [cal components:unitFlags fromDate:date];	
	if ([comps year] == 1874 && [comps month] == 3 && [comps day] == 24) {
		InstructionsViewController* viewController = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:nil];
		[self presentModalViewController:viewController animated:NO	];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Incorrect." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];	
		alert.frame = CGRectMake(10, 159, 300, 250);
		[alert show];		
		[alert release];
	}
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
