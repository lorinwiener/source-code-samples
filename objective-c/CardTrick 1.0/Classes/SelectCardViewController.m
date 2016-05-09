//
//  SelectCardViewController.m
//  CardTrick 1.2
//
//  Created by Lorin Wiener on 09/05/09.
//  Copyright 2008 SharperMinds. All rights reserved.
//

#import "SelectCardViewController.h"
#import <Coregraphics/CoreGraphics.h>


@implementation SelectCardViewController


- (id) initWithNibName:(NSString *) nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}	
	return self;
}

-(void) initializeArrays {
	numCardsFaceUp = 0;
	positionOfFirstCardSelected = 0;
	nameOfFirstCardSelected = @"null";
	cardStateArray =  [[NSMutableArray  arrayWithObjects:@"down", @"down", @"down", @"down", @"down", nil] retain];
	cardsFaceUpArray =  [[NSMutableArray  arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil] retain];
	faceCardsArray = [[NSMutableArray  arrayWithObjects:@"h11", @"h12", @"h13", @"s11", @"s12", @"s13", @"c11", @"c12", @"c13", @"d11", @"d12", @"d13",nil] retain];
	symmetricDeckArray =[[NSMutableArray  arrayWithObjects:@"h2", @"h4", @"h10", @"h11", @"h12", @"h13", @"s2", @"s4", @"s10", @"s11", @"s12", 
						  @"s13", @"d1", @"d2", @"d3", @"d4", @"d5", @"d6", @"d8", @"d9", @"d10", @"d11", @"d12", 
						  @"d13", @"c2", @"c4", @"c10", @"c11", @"c12", @"c13",nil] retain];
	nonSymmetricDeckArray = [[NSMutableArray  arrayWithObjects:@"h1", @"h3", @"h5", @"h6", @"h7", @"h8", @"h9", @"h11", @"h12", @"h13", @"s1", @"s3",
							  @"s5", @"s6", @"s7", @"s8", @"s9", @"s11", @"s12", @"s13", @"c1", @"c3", @"c5", @"c6", 
							  @"c7", @"c8", @"c9", @"c11", @"c12", @"c13", @"d11", @"d12", @"d13",nil] retain];
	limitedSymmetricDeckArray = [[NSMutableArray  arrayWithObjects:@"h2", @"h4", @"h10", @"s2", @"s4", @"s10", @"d1", @"d2", @"d3", @"d4", @"d5", @"d6",
								  @"d8", @"d9", @"d10", @"c2", @"c4", @"c10",nil] retain];
	fullDeckArray = [[NSMutableArray  arrayWithObjects:@"h1", @"h2", @"h3", @"h4", @"h5", @"h6", @"h7", @"h8", @"h9", @"h10", @"h11", @"h12", @"h13",
					  @"c1", @"c2", @"c3", @"c4", @"c5", @"c6", @"c7", @"c8", @"c9", @"c10", @"c11", @"c12", @"c13", 
					  @"s1", @"s2", @"s3", @"s4", @"s5", @"s6", @"s7", @"s8", @"s9", @"s10", @"s11", @"s12", @"s13", 
					  @"d1", @"d2", @"d3", @"d4", @"d5", @"d6", @"d7", @"d8", @"d9", @"d10", @"d11", @"d12", @"d13",nil] retain];
}

// If you need to do additional setup after loading the view, override viewDidLoad.
- (void) viewDidLoad {
	cardArray = [[NSMutableArray arrayWithObjects:cardImageView1, cardImageView2, cardImageView3, cardImageView4, cardImageView5, nil] retain];
	float offsetX = 8;	
	float offsetY = 103;
	float cardWidth = 88;
	float cardDistance = 5;	
	cardImageView1.frame = CGRectMake(offsetX, offsetY, cardWidth, 114);
	cardImageView2.frame = CGRectMake(offsetX + (cardWidth + cardDistance) * 1, offsetY, cardWidth, 114);
	cardImageView3.frame = CGRectMake(offsetX + (cardWidth + cardDistance) * 2, offsetY, cardWidth, 114);
	cardImageView4.frame = CGRectMake(offsetX + (cardWidth + cardDistance) * 3, offsetY, cardWidth, 114);
	cardImageView5.frame = CGRectMake(offsetX + (cardWidth + cardDistance) * 4, offsetY, cardWidth, 114);	
	cardImageView4.userInteractionEnabled = YES;
	cardImageView5.userInteractionEnabled = YES;
	[self initializeArrays];
	[UIView setAnimationsEnabled:NO];
	[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];
	backImage = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"]] retain];
}

- (void) viewDidAppear:(BOOL) animated {
	self.view.bounds = CGRectMake(0, 0, 320, 480);
	self.view.frame = CGRectMake(0, 0, 320, 480);		
}

-(NSString*) up:(int) position {
	int cardPositionNumber = position;
	// Record the position of this card if it is the first card selected 
	if (numCardsFaceUp == 0) {
		positionOfFirstCardSelected = cardPositionNumber;
	}
	// If this is the first card selected use a nonSymmetric deck 	
	if (numCardsFaceUp == 0) {		
		deckArray = nonSymmetricDeckArray;
	} else {
		//If this card is to the right of the first card selected use a full deck unless the first card selected was a face card.  In that case use a symmetric deck. 		
		if (cardPositionNumber > positionOfFirstCardSelected) {	
			if([faceCardsArray containsObject:nameOfFirstCardSelected]){
				deckArray = symmetricDeckArray;				
			} else {				
				deckArray = fullDeckArray;				
			}			
		}
		// If this card is to the left of the first card selected use a symmetric deck unless the first card selected was a face card.  In that case use a limited symmetric deck which contains no face cards.  
		if (cardPositionNumber < positionOfFirstCardSelected) {			
			if ([faceCardsArray containsObject:nameOfFirstCardSelected]) {				
				deckArray = limitedSymmetricDeckArray;				
			} else {				
				deckArray = symmetricDeckArray;				
			}			
		}
	}
	// Eliminate possibility of a random card being a duplicate of a card already facing upward	
	int randomNumber;
	NSString* randomCard;
	do {		
		// Pick a random number between 0 and the length of the deck
		randomNumber = arc4random() % [deckArray count];		
		// Pick a random card from the deck
		randomCard = [deckArray objectAtIndex:randomNumber];		
	} while ([cardsFaceUpArray containsObject:randomCard]);
	// Record the name of the first card selected 		
	if (numCardsFaceUp == 0) {		
		nameOfFirstCardSelected = randomCard;		
	}
	// Place this random card in the proper position of the cardsFaceUpArray 
	[cardsFaceUpArray replaceObjectAtIndex:cardPositionNumber - 1 withObject:randomCard];
	// Increase the number of cards face up count 	
	numCardsFaceUp = numCardsFaceUp + 1;	
	return [randomCard retain];
}

-(NSString*) down:(int) position {	
	int cardPositionNumber = position;
	// If this is the last card to turn face down 	
	if (numCardsFaceUp == 1) {		
		// Initialize all the variables and lists to start trick over 		
		[self initializeArrays];	
		// If this is not the last card to turn face down		
	} else {	
		// Remove this card from the proper position of the cardsFaceUpArray 
		//[cardsFaceUpArray removeObjectAtIndex:cardPositionNumber - 1];	
		[cardsFaceUpArray replaceObjectAtIndex:cardPositionNumber - 1 withObject:[NSString stringWithFormat:@"%d",cardPositionNumber]];
		// Decrease the number of cards face up count 		
		numCardsFaceUp = numCardsFaceUp - 1;		
	}	
	return @"back";
}

-(void) click:(int) position {	
	if ([[cardStateArray objectAtIndex:position-1] isEqualToString:@"down"]) {
		[cardStateArray replaceObjectAtIndex:position-1 withObject:@"up"];		
		NSLog(@"up=>cardArray objectAtIndex:%d, cardArray count:%d", position-1, [cardArray count]);
		((UIImageView*)[cardArray objectAtIndex:position-1]).image = 
		[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[self up:position] ofType:@"png"]];
	} else if([[cardStateArray objectAtIndex:position-1] isEqualToString:@"up"]){
		[cardStateArray replaceObjectAtIndex:position-1 withObject:@"down"];
		[self down:position];
		NSLog(@"down=>cardArray objectAtIndex:%d, cardArray count:%d", position-1, [cardArray count]);
		((UIImageView*)[cardArray objectAtIndex:position-1]).image = backImage; 
	}		
}

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event {
	UITouch* touch = [touches anyObject];	
	for(int i=0;i<[cardArray count];i++){		 
		if([touch.view isEqual:[cardArray objectAtIndex:i]]){
			int position=i+1;
			[self click:position];
			break;
		}		
	}
	[super touchesBegan:touches withEvent:event];	
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {	
	// Return YES for supported orientations
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) { 
		return YES;
	}
	return NO;
}

- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[super dealloc];
}

@end
