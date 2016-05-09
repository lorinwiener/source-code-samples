package com.fireball.laserNodes {
	
	import com.fireball.laserNodes.events.*;
	import com.fireball.laserNodes.mvc.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.sensors.Accelerometer;
	import flash.utils.Timer;
	import flash.media.SoundMixer;
	
	import FacilityEvents.*;
	
	
	/**
	 * Concrete MVC Model to store application data and application logic
	 */
	public class LaserNodesModel extends Model
	{
		
		private static var _instance:LaserNodesModel;
		
		private const _gameDuration:Number = 120; // Seconds
		
		private var _timer:Timer;
		private var _totalSecondsLeft:Number;
		private var _powerLevel;
		private var _selectedGamePiece:Object;
		private var _gamePiecesPlacedCorrectlyArray:Array;
		private var _conflictingGamePiecesArray:Array;
		private var _isGamePiecesWaitingForLightningBolts:Boolean;
		
		private var _currentTime:String;
		
		
		public function LaserNodesModel ()
		{
			init ();
		}
		
		override protected function updateData () : void
		{
			dispatchEvent(new Event(Model.MODEL_CHANGE));
		}
		
		public static function getInstance () : LaserNodesModel
		{
			if (_instance == null)
			{
				LaserNodesModel._instance = new LaserNodesModel ();
			}
			return LaserNodesModel._instance;
		}
		
		private function init () : void
		{
			_currentTime = formatTime(_gameDuration);
			_timer = new Timer(1000, _gameDuration);
			_timer.addEventListener(TimerEvent.TIMER, updateTime);
			_totalSecondsLeft = _gameDuration;
			_powerLevel = 0;
			_gamePiecesPlacedCorrectlyArray = new Array();
			_conflictingGamePiecesArray = new Array();
			_isGamePiecesWaitingForLightningBolts = false;
			updateData();
		}
		
		private function updateTime(event:TimerEvent)
		{
			_totalSecondsLeft = _gameDuration - _timer.currentCount;
			_currentTime = formatTime(_totalSecondsLeft);
			updateData();
			if (_totalSecondsLeft == 0)
			{
				endGame();
			}
		}
		
		private function placeSelectedGamePieceOnBoard(argSelectedGamePiece:Object, argHitArea:Object) : void
		{
			dispatchEvent(new GamePieceEvent(GamePieceEvent.PLACE_SELECTED_GAME_PIECE_ON_BOARD, {selectedGamePiece:argSelectedGamePiece, hitArea:argHitArea}));
		}
		
		private function returnSelectedGamePieceToHomePosition(argSelectedGamePiece:Object) : void
		{
			dispatchEvent(new GamePieceEvent(GamePieceEvent.RETURN_SELECTED_GAME_PIECE_TO_HOME_POSITION, {selectedGamePiece:argSelectedGamePiece}));
		}
		
		private function returnConflictingGamePiecesToHomePosition(argConflictingGamePiecesArray:Array) : void
		{
			for (var i:uint = 0; i < argConflictingGamePiecesArray.length; i++)
			{
				var conflictingGamePieceObject:Object;
				conflictingGamePieceObject = argConflictingGamePiecesArray[i];
				dispatchEvent(new GamePieceEvent(GamePieceEvent.RETURN_CONFLICTING_GAME_PIECE_TO_HOME_POSITION, {conflictingGamePiece:conflictingGamePieceObject}));
			}
		}
		
		private function returnSelectedAndConflictingGamePiecesToHomePositionWithLightning(argSelectedGamePiece:Object, argConflictingGamePiecesArray:Array) : void
		{
			dispatchEvent(new GamePieceEvent(GamePieceEvent.RETURN_SELECTED_AND_CONFLICTING_GAME_PIECES_TO_HOME_POSITION_WITH_LIGHTNING, {selectedGamePiece:argSelectedGamePiece, conflictingGamePiecesArray:argConflictingGamePiecesArray}));
		}
		
		private function returnAllGamePiecesToHomePosition() : void
		{
			dispatchEvent(new GamePieceEvent(GamePieceEvent.RETURN_ALL_GAME_PIECES_TO_HOME_POSITION, null));
		}
		
		private function formatTime(argSeconds:int) : String
		{
			var time:String;
			var seconds:Number = Math.floor(argSeconds);
			var minutes:Number = Math.floor(seconds / 60);
			var hours:Number = Math.floor(minutes / 60);
			var days:Number = Math.floor(hours / 24);
			
			seconds %= 60;
			minutes %= 60;
			hours %= 24;
			
			var sec:String = seconds.toString();
			var min:String = minutes.toString();
			var hrs:String = hours.toString();
			var d:String = days.toString();
			
			if (sec.length < 2) {
				sec = "0" + sec;
			}
			
			if (min.length < 2) {
				min = "0" + min;
			}
			
			if (hrs.length < 2) {
				hrs = "0" + hrs;
			}
			
			time = d + ":" + hrs + ":" + min + ":" + sec;
			
			return time;
		}
		
		private function resetTimer() : void
		{
			_currentTime = formatTime(_gameDuration);
			_timer.reset();
			updateData();
		}
		
		// Modify game pieces placed correctly array
		private function addToGamePiecesPlacedCorrectlyArray(argGamePiece:Object) : void
		{
			_gamePiecesPlacedCorrectlyArray.push(argGamePiece);
			increasePowerLevel();
			updateData();
		}
		
		private function removeFromGamePiecesPlacedCorrectlyArray(argGamePiece:Object) : void
		{
			_gamePiecesPlacedCorrectlyArray.splice(_gamePiecesPlacedCorrectlyArray.indexOf(argGamePiece), 1);
			decreasePowerLevel();
			updateData();
		}
		
		private function resetGamePiecesPlacedCorrectlyArray() : void
		{
			_gamePiecesPlacedCorrectlyArray = [];
			resetPowerLevel();
			updateData();
		}
		
		// Modify conflicting game pieces array
		private function addToConflictingGamePiecesArray(argGamePiece:Object)
		{
			_conflictingGamePiecesArray.push(argGamePiece);
			updateData();
		}
		
		private function removeFromConflictingGamePiecesArray(argGamePiece:Object) : void
		{
			_conflictingGamePiecesArray.splice(_conflictingGamePiecesArray.indexOf(argGamePiece), 1);
			updateData();
		}
		
		private function resetConflictingGamePiecesArray() : void
		{
			_conflictingGamePiecesArray = [];
			updateData();
		}
		
		private function increasePowerLevel() : void
		{
			if (_powerLevel < 5)
			{
				_powerLevel++;
				
				updateData();
			}
		}
		
		private function decreasePowerLevel() : void
		{
			_powerLevel--;
			
			if (_powerLevel < 0)
			{
				_powerLevel = 0;
			}
			
			updateData();
		}
		
		private function resetPowerLevel() : void
		{
			_powerLevel = 0;
			updateData();
		}
		
		private function isCapturable(argSelectedGamePiece:MovieClip) : Boolean
		{
			_conflictingGamePiecesArray = [];
			
			for (var i:uint = 0; i < _gamePiecesPlacedCorrectlyArray.length; i++)
			{
				if (argSelectedGamePiece != _gamePiecesPlacedCorrectlyArray[i])
				{
					var dx:Number;
					var dy:Number;
					var angleRadians:Number;
					var angleDegrees:Number
					
					dy = argSelectedGamePiece.y - _gamePiecesPlacedCorrectlyArray[i].y;
					dx = argSelectedGamePiece.x - _gamePiecesPlacedCorrectlyArray[i].x;
					
					angleRadians = Math.atan2(dy, dx);
					
					angleDegrees = Math.round(angleRadians * 180 / Math.PI);
					
					if (angleDegrees%45 == 0)
					{
						addToConflictingGamePiecesArray(_gamePiecesPlacedCorrectlyArray[i]);
					}
				}
			}
			
			if (_conflictingGamePiecesArray.length > 0)
			{
				return true;
			} else {
				return false;
			}
			
		}
		
		public function endGame() : void
		{
			// Todo: Play a sound
			
			returnAllGamePiecesToHomePosition();
			resetGamePiecesPlacedCorrectlyArray();
			resetConflictingGamePiecesArray();
			resetPowerLevel();
			resetTimer();
		}
		
		public function gameSolved() : void
		{
			//stopTimer();
			//stopAllSounds();
			dispatchEvent(new Event("LASER_NODES_SOLVED"));
		}
		
		public function moveSelectedGamePiece (argSelectedGamePiece:MovieClip, invalidBoardHitAreaArray:Array, boardHitAreaArray:Array) : void
		{
			var selectedGamePieceXPos = argSelectedGamePiece.x;
			var selectedGamePieceYPos = argSelectedGamePiece.y;
			
			_selectedGamePiece = argSelectedGamePiece;
			
			// Check for placement of game pieces over invalid regions of game board
			for (var i:uint = 0; i < invalidBoardHitAreaArray.length; i++)
			{
				if (invalidBoardHitAreaArray[i].hitTestPoint(selectedGamePieceXPos, selectedGamePieceYPos, true))
				{			
					returnSelectedGamePieceToHomePosition(argSelectedGamePiece);
					if (_gamePiecesPlacedCorrectlyArray.indexOf(argSelectedGamePiece) != -1)
					{
						removeFromGamePiecesPlacedCorrectlyArray(argSelectedGamePiece);
					}
					return;
				}	
			}
			
			// Check for placement of game pieces over game pieces already on the game board
			for (var j:uint = 0; j < _gamePiecesPlacedCorrectlyArray.length; j++)
			{
				if (_gamePiecesPlacedCorrectlyArray[j].hitTestPoint(selectedGamePieceXPos, selectedGamePieceYPos, true) && _gamePiecesPlacedCorrectlyArray[j] != argSelectedGamePiece)
				{			
					returnSelectedGamePieceToHomePosition(argSelectedGamePiece);
					if (_gamePiecesPlacedCorrectlyArray.indexOf(argSelectedGamePiece) != -1)
					{
						removeFromGamePiecesPlacedCorrectlyArray(argSelectedGamePiece);
					}
					return;
				}	
			}
			
			// Check for placement of game pieces over valid regions of game board
			for (var k:uint = 0; k < boardHitAreaArray.length; k++)
			{
				if (boardHitAreaArray[k].hitTestPoint(selectedGamePieceXPos, selectedGamePieceYPos, true))
				{	
					placeSelectedGamePieceOnBoard(argSelectedGamePiece, boardHitAreaArray[k]);
					
					// Check for placement of game pieces in locations where they can be captured
					if (isCapturable(argSelectedGamePiece) == true)
					{
						// Return selected and conflicting game pieces to their home positions and display lightning
						
						_isGamePiecesWaitingForLightningBolts = true;
						
						returnSelectedAndConflictingGamePiecesToHomePositionWithLightning(argSelectedGamePiece, _conflictingGamePiecesArray);
						
						// Remove selected game piece from the game pieces placed correctly array if game piece was already placed correctly
						if (_gamePiecesPlacedCorrectlyArray.indexOf(argSelectedGamePiece) != -1)
						{
							removeFromGamePiecesPlacedCorrectlyArray(argSelectedGamePiece);
						}
						
						// Remove conflicting game pieces from conflicting game piece array since they have been returned home
						for (var x:uint = 0; x < _conflictingGamePiecesArray.length; x++)
						{
							var conflictingGamePieceObject:Object;
							conflictingGamePieceObject = _conflictingGamePiecesArray[x];
							removeFromGamePiecesPlacedCorrectlyArray(conflictingGamePieceObject);
						}
						
						return;
						
					} else {
						// Add selected game piece to game pieces placed correctly array
						if (_gamePiecesPlacedCorrectlyArray.indexOf(argSelectedGamePiece) == -1)
						{
							addToGamePiecesPlacedCorrectlyArray(argSelectedGamePiece);
						}
						return;
					}
				}
			}
			
			// Handle placement of game pieces outside of game board
			returnSelectedGamePieceToHomePosition(argSelectedGamePiece);
			if (_gamePiecesPlacedCorrectlyArray.indexOf(argSelectedGamePiece) != -1)
			{
				removeFromGamePiecesPlacedCorrectlyArray(argSelectedGamePiece);
			}
			
		}
		
		public function startTimer() : void
		{
			if (_totalSecondsLeft == _gameDuration)
			{
				_timer.start();
			} else if (_totalSecondsLeft == 0) {
				resetTimer();
				_timer.start();
			}
			updateData();
		}
		
		public function stopTimer() : void
		{
			_timer.stop();
		}
		
		public function stopAllSounds() : void
		{
			SoundMixer.stopAll();
		}
		
		public function get powerLevel() : Number
		{
			return _powerLevel;
		}
		
		public function get currentTime() : String
		{
			return _currentTime;
		}
		
		public function get selectedGamePiece() : Object
		{
			return _selectedGamePiece;
		}
		
		public function get gamePiecesPlacedCorrectlyArray() : Array
		{
			return _gamePiecesPlacedCorrectlyArray;
		}
		
		public function get conflictingGamePiecesArray() : Array
		{
			return _conflictingGamePiecesArray;
		}
		
		public function get isGamePiecesWaitingForLightningBolts() : Boolean
		{
			return _isGamePiecesWaitingForLightningBolts;
		}
		
		public function set isGamePiecesWaitingForLightningBolts(argIsGamePiecesWaitingForLightningBolts:Boolean)
		{
			_isGamePiecesWaitingForLightningBolts = argIsGamePiecesWaitingForLightningBolts;
		}
		
	}
	
}
