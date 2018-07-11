// Copyright (C) 2008 e-tricks.com. All Rights Reserved.

var cardValue;
var containerName;
var cardContainer1;
var cardContainer2;
var cardContainer3;
var cardContainer4;
var cardContainer5;

var cardPositionString;
var cardPositionNumber;
var cardsFaceUpArray;
var cardsFaceUpString;
var deckArray;
var faceCardsArray;
var faceCardsString;
var fullDeckArray;
var limitedSymmetricDeckArray;
var nonSymmetricDeckArray;
var nonSymmetricDeckString;
var nameOfFirstCardSelectedArray;
var nameOfFirstCardSelectedString;
var numCardsFaceUp;
var positionOfFirstCardSelected;
var symmetricDeckArray;

window.addEventListener('load', init, false);


function init() {
	
	initializeArrays();
	
	cardContainer1 = document.getElementById('cardContainer');
	cardContainer2 = document.getElementById('cardContainer');
	cardContainer3 = document.getElementById('cardContainer');
	cardContainer4 = document.getElementById('cardContainer');
	cardContainer5 = document.getElementById('cardContainer');
	
	createCard(1, cardContainer1, 5, 36);
	createCard(2, cardContainer2, 97, 36);
	createCard(3, cardContainer3, 189, 36);
	createCard(4, cardContainer4, 282, 36);
	createCard(5, cardContainer5, 376, 36);
}


function initializeArrays() {
	
	numCardsFaceUp = 0;
	positionOfFirstCardSelected = 0;
	nameOfFirstCardSelectedArray = new Array("null");
	cardsFaceUpArray = new Array("1", "2", "3", "4", "5");
	faceCardsArray = new Array("h11", "h12", "h13", "s11", "s12", "s13", "c11", "c12", "c13", "d11", "d12", "d13");
	symmetricDeckArray = new Array("h2", "h4", "h10", "h11", "h12", "h13", "s2", "s4", "s10", "s11", "s12", "s13", "d1", "d2", "d3", "d4", "d5", "d6", "d8", "d9", "d10", "d11", "d12", "d13", "c2", "c4", "c10", "c11", "c12", "c13");
	nonSymmetricDeckArray = new Array("h1", "h3", "h5", "h6", "h7", "h8", "h9", "h11", "h12", "h13", "s1", "s3", "s5", "s6", "s7", "s8", "s9", "s11", "s12", "s13", "c1", "c3", "c5", "c6", "c7", "c8", "c9", "c11", "c12", "c13", "d11", "d12", "d13");
	limitedSymmetricDeckArray = new Array("h2", "h4", "h10", "s2", "s4", "s10", "d1", "d2", "d3", "d4", "d5", "d6", "d8", "d9", "d10", "c2", "c4", "c10");
	fullDeckArray = new Array("h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9", "h10", "h11", "h12", "h13", "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10", "c11", "c12", "c13", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "s12", "s13", "d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9", "d10", "d11", "d12", "d13");
	
}


function createCard(cardPositionNumber, containerName, xPos, yPos) {
	
	var image = document.createElement('image');
	
	image.src = 'images/back.png';
	image.state = "DOWN";
	image.setAttribute("onclick", "click(" + cardPositionNumber + ")");
	
	image.style.top = pixelValue(yPos);
	image.style.left = pixelValue(xPos);
	
	containerName.appendChild(image);
	
}


function click(position) {	
	
	if (document.images[position - 1].state == "DOWN") {
		
		document.images[position - 1].state = "UP";
		
		newSrc = "images/" + up(position) + ".png";
		
	} else if(document.images[position - 1].state == "UP") {
		
		document.images[position - 1].state = "DOWN";
		
		newSrc = "images/" + down(position) + ".png";
		
	}
	
	document.images[position - 1].src = newSrc;
	
}


function pixelValue(value) {
	
	return value + 'px';
	
}


function up(position) {
	
	cardsFaceUpString = cardsFaceUpArray.toString();
	faceCardsString = faceCardsArray.toString();
	nonSymmetricDeckString = nonSymmetricDeckArray.toString();
	cardPositionNumber = Number(position);
	nameOfFirstCardSelectedString = nameOfFirstCardSelectedArray.toString();
	
	// Record the position of this card if it is the first card selected 
	
	if (numCardsFaceUp == 0) {
		positionOfFirstCardSelected = cardPositionNumber;
	}
	
	// If this is the first card selected use a nonSymmetric deck 
	
	if (numCardsFaceUp == 0) {
		
		deckArray = nonSymmetricDeckArray;
		
	} else {
		
		/* If this card is to the right of the first card selected use a full deck,
		   unless the first card selected was a face card.  In that case use a symmetric deck. */
		
		if (cardPositionNumber>positionOfFirstCardSelected) {
			
			if (faceCardsArray.toString().indexOf(nameOfFirstCardSelectedArray.toString()) != -1) {
				
				deckArray = symmetricDeckArray;
				
			} else {
				
				deckArray = fullDeckArray;
				
			}
			
		}
		
		// If this card is to the left of the first card selected use a symmetric deck, unless the first card selected was a face card.  In that case use a limited symmetric deck which contains no face cards.  
		
		if (cardPositionNumber < positionOfFirstCardSelected) {
			
			if (faceCardsArray.toString().indexOf(nameOfFirstCardSelectedArray.toString()) != -1) {
				
				deckArray = limitedSymmetricDeckArray;
				
			} else {
				
				deckArray = symmetricDeckArray;
				
			}
			
		}
	}
	
	// Eliminate possibility of a random card being a duplicate of a card already facing upward
	
	do {
		
		// Pick a random number between 0 and the length of the deck
		
		randomNumber = Math.floor(Math.random()*Math.floor(deckArray.length));
		
		// Pick a random card from the deck 
		
		randomCard = deckArray.slice(randomNumber-1, randomNumber);
	
	} while (cardsFaceUpArray.toString().indexOf(randomCard.toString()) != -1);
	
	// Record the name of the first card selected 
	
	if (numCardsFaceUp == 0) {
		
		nameOfFirstCardSelectedArray.splice(0, 1);
		nameOfFirstCardSelectedArray.splice(0, 1, randomCard.toString());
		
	}
	
	// Place this random card in the proper position of the cardsFaceUpArray 
	
	cardsFaceUpArray.splice((cardPositionNumber - 1), 1);
	cardsFaceUpArray.splice((cardPositionNumber - 1), 0, randomCard.toString());
	
	// Increase the number of cards face up count 
	
	numCardsFaceUp = numCardsFaceUp + 1;
	
	// Display the graphic on screen 
	
	return randomCard;
	
}


function down(position) {	
	
	cardPositionNumber = Number(position);
	
	// If this is the last card to turn face down 
	
	if (numCardsFaceUp == 1) {
		
		// Initialize all the variables and lists to start trick over 
		
		initializeArrays();
		
		// If this is not the last card to turn face down
		
	} else {
		
		// Remove this card from the proper position of the cardsFaceUpArray 
		
		cardsFaceUpArray.splice((cardPositionNumber - 1), 1);
		cardsFaceUpArray.splice((cardPositionNumber - 1), 0, cardPositionNumber.toString());
		
		// Decrease the number of cards face up count 
		
		numCardsFaceUp = numCardsFaceUp - 1;
		
	}
	
	return "back";
	
}