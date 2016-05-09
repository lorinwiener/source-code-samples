﻿/* Copyright (c) 2011  Lorin Wiener  <lorin@lorinwiener.com> All rights reserved. */package{		//--------------------------------------	// IMPORTS	//--------------------------------------	import flash.display.*;		import com.sharperminds.cardTrick.mvc.*		//--------------------------------------	// CLASS	//--------------------------------------	/**	 *  Document class for an application that allows user to perform an interactive magic trick using the following secret:	 *  The secret:  Scan your eyes across the centerline pips of the cards from left to right.	  * The first card from the left with a non-symmetric centerline pip is the first card that was selected by the spectator.	  *  If no such pip is found, then the first face card from the left is the first card that was selected by the spectator.	  */	public class CardTrickDocument extends Sprite	{				//--------------------------------------		// PROPERTIES		//--------------------------------------						//--------------------------------------		// PUBLIC CONSTANTS		//--------------------------------------		public var cardTrickContainer_mc : Sprite;				public var cardTrickModel:CardTrickModel;		public var cardTrickController:CardTrickController;		public var cardTrickView:CardTrickView;						//--------------------------------------		// CONSTRUCTOR		//--------------------------------------		public function CardTrickDocument()		{						addCardTrickContainer ();						// Create Singleton Instance Of CardTrickModel			cardTrickModel = new CardTrickModel.getInstance ();			cardTrickController = new CardTrickController (cardTrickModel);			cardTrickView = new CardTrickView (cardTrickModel, cardTrickController, cardTrickContainer_mc);				}				//--------------------------------------		// METHODS		//--------------------------------------		public function addCardTrickContainer () :void		{			cardTrickContainer_mc = new Sprite ();			addChild (cardTrickContainer_mc);		}		}	}