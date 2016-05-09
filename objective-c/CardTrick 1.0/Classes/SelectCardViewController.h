//
//  SelectCardViewController.h
//  CardTrick 1.2
//
//  Created by Lorin Wiener on 09/05/09.
//  Copyright 2008 SharperMinds. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectCardViewController : UIViewController {
	
	NSMutableArray* cardArray;
	NSMutableArray* cardStateArray;
	NSMutableArray* cardsFaceUpArray;
	NSMutableArray* faceCardsArray;
	NSMutableArray* symmetricDeckArray;
	NSMutableArray* nonSymmetricDeckArray;
	NSMutableArray* limitedSymmetricDeckArray;
	NSMutableArray* fullDeckArray;
	NSMutableArray* deckArray;
	
	IBOutlet UIImageView* cardImageView1;
	IBOutlet UIImageView* cardImageView2;
	IBOutlet UIImageView* cardImageView3;
	IBOutlet UIImageView* cardImageView4;
	IBOutlet UIImageView* cardImageView5;
		
	NSString* nameOfFirstCardSelected;
	
	int numCardsFaceUp ;
	int positionOfFirstCardSelected ;	
	
	UIImage* backImage;
	
}

@end
