package com.fireball.laserNodes {

	import flash.display.*;
	import flash.events.*;
	
	import com.fireball.laserNodes.mvc.*;

	
	/**
	 * Concrete MVC controller class to handle communication from view to model
	*/
	public class LaserNodesController extends Controller
	{
		/**
	 	 * Contructor to establish the model for the MVC architecture
		*/
		public function LaserNodesController (argModel : Model)
		{
			super (argModel);
		}
		
		public function getGamePiecesPlacedCorrectlyArray() : Array
		{
			return model.gamePiecesPlacedCorrectlyArray;
		}
		
		public function addToGamePiecesPlacedCorrectlyArray(argGamePiece:Object) : void
		{
			model.addToGamePiecesPlacedCorrectlyArray(argGamePiece);
		}
		
		public function removeFromGamePiecesPlacedCorrectlyArray(argGamePiece:Object) : void
		{
			model.removeFromGamePiecesPlacedCorrectlyArray(argGamePiece);
		}
		
		public function getSelectedGamePiece() : Object
		{
			return model.selectedGamePiece;
		}
		
		public function getConflictingGamePiecesArray() : Array
		{
			return model.conflictingGamePiecesArray;
		}
		
		public function gameSolved() : void
		{
			model.gameSolved();
		}
		
		public function getPowerLevel ()
		{
			return model.powerLevel;
		}
		
		public function getCurrentTime ()
		{
			return model.currentTime;
		}
		
		public function getIsGamePiecesWaitingForLightningBolts()
		{
			return model.isGamePiecesWaitingForLightningBolts;
		}
		
		public function setIsGamePiecesWaitingForLightningBolts(argIsGamePiecesWaitingForLightningBolts:Boolean)
		{
			model.isGamePiecesWaitingForLightningBolts = argIsGamePiecesWaitingForLightningBolts;
		}
		
		public function startTimer() : void
		{
			//model.startTimer();
		}
		
		public function moveSelectedGamePiece(argSelectedGamePiece:Object, argInvalidBoardHitAreaArray:Array, argBoardHitAreaArray:Array)
		{
			model.moveSelectedGamePiece(argSelectedGamePiece, argInvalidBoardHitAreaArray, argBoardHitAreaArray)
		}
	}
	
}
