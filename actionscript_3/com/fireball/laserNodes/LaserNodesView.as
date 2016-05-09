package com.fireball.laserNodes
{
	
	import Achievements.Achievement;
	import com.fireball.laserNodes.*;
	import com.fireball.laserNodes.events.*;
	import com.fireball.laserNodes.mvc.*;
	import com.fireball.utils.*;
	import com.greensock.*;
	
	import fl.motion.AdjustColor;
	import fl.motion.Color;
	import fl.motion.easing.*;
	
	import flash.display.*;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.media.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	
	
	/**
	 * View class for MVC architecture to handle the assets displayed on stage, the events they trigger, and the communication of the
	 * view with the model via the controller.
	 */
	public class LaserNodesView extends View
	{
		
		
		private const SFX_DIRECTORY = "sfx/laserNodes/";
		
		private const BOARD_HIT_AREA_ORIGIN_X = 296.00;
		private const BOARD_HIT_AREA_ORIGIN_Y = 143.5;
		private const BOARD_HIT_AREA_SPACING = 0;
		
		private const GAME_PIECES_HOME_ORIGIN_X = 802.5;
		private const GAME_PIECES_HOME_ORIGIN_Y = 190.5;
		
		private const GAME_PIECE_HOME_POSITION_SPACING = -64.0;
		
		private const GAME_PIECE_HOME_POSITION_DIMENSION = 52.9;
		private const GAME_PIECE_DRAG_DIMENSION = 75;
		private const GAME_PIECE_ON_BOARD_DIMENSION = 58.0;
		
		private var GAME_PIECE_01_HOME_Y_POS;
		private var GAME_PIECE_02_HOME_Y_POS;
		private var GAME_PIECE_03_HOME_Y_POS;
		private var GAME_PIECE_04_HOME_Y_POS;
		private var GAME_PIECE_05_HOME_Y_POS;
		
		private const GAME_PIECE_MOUSE_DOWN_VOLUME = 1;
		private const GAME_PIECE_MOUSE_UP_VOLUME = 1;
		private const LIGHTNING_VOLUME = 2;
		private const POWER_LEVEL_00_HUM_VOLUME = 1;
		private const POWER_LEVEL_01_HUM_VOLUME = 1;
		private const POWER_LEVEL_02_HUM_VOLUME = .7;
		private const POWER_LEVEL_03_HUM_VOLUME = 1.2;
		private const POWER_LEVEL_04_HUM_VOLUME = 1.3;
		private const POWER_LEVEL_05_HUM_VOLUME = 1;
		private const POWER_LEVEL_06_HUM_VOLUME = 1;
		
		private var _isTestingMode:Boolean;
		
		private var _gamePieceMouseDown_snd:Sound;
		private var _gamePieceMouseUp_snd:Sound;
		private var _lightning_snd:Sound;
		private var _powerLevel_00_Hum_snd:PowerLevel00HumMP3;
		private var _powerLevel_01_Hum_snd:PowerLevel01HumMP3;
		private var _powerLevel_02_Hum_snd:PowerLevel02HumMP3;
		private var _powerLevel_03_Hum_snd:PowerLevel03HumMP3;
		private var _powerLevel_04_Hum_snd:PowerLevel04HumMP3;
		private var _powerLevel_05_Hum_snd:PowerLevel05HumMP3;
		private var _powerLevel_06_Hum_snd:PowerLevel06HumMP3;
		
		private var _gamePieceMouseDown_stf:SoundTransform;
		private var _gamePieceMouseUp_stf:SoundTransform;
		private var _lightning_stf:SoundTransform;
		private var _powerLevel_00_Hum_stf:SoundTransform;
		private var _powerLevel_01_Hum_stf:SoundTransform;
		private var _powerLevel_02_Hum_stf:SoundTransform;
		private var _powerLevel_03_Hum_stf:SoundTransform;
		private var _powerLevel_04_Hum_stf:SoundTransform;
		private var _powerLevel_05_Hum_stf:SoundTransform;
		private var _powerLevel_06_Hum_stf:SoundTransform;
		
		private var _powerLevel_00_Hum_sch:SoundChannel;
		private var _powerLevel_01_Hum_sch:SoundChannel;
		private var _powerLevel_02_Hum_sch:SoundChannel;
		private var _powerLevel_03_Hum_sch:SoundChannel;
		private var _powerLevel_04_Hum_sch:SoundChannel;
		private var _powerLevel_05_Hum_sch:SoundChannel;
		private var _powerLevel_06_Hum_sch:SoundChannel;
		
		private var _powerLevel05Timer:Timer;
		private var _powerLevel06Timer:Timer;
		
		private var _isPlayingPowerLevel00GameBoardAnimation:Boolean = false;
		private var _isPlayingPowerLevel01GameBoardAnimation:Boolean = false;
		private var _isPlayingPowerLevel02GameBoardAnimation:Boolean = false;
		private var _isPlayingPowerLevel03GameBoardAnimation:Boolean = false;
		private var _isPlayingPowerLevel04GameBoardAnimation:Boolean = false;
		private var _isPlayingPowerLevel05GameBoardAnimation:Boolean = false;
		
		private var _gamePieceConstraintRectangle:Rectangle;
				
		private var _selectedGamePieceOrigXPos:Number;
		private var _selectedGamePieceOrigYPos:Number;
		
		private var _conflictingGamePiece_01_OrigXPos:Number;
		private var _conflictingGamePiece_01_OrigYPos:Number;
		
		private var _conflictingGamePiece_02_OrigXPos:Number;
		private var _conflictingGamePiece_02_OrigYPos:Number;
		
		private var _conflictingGamePiece_03_OrigXPos:Number;
		private var _conflictingGamePiece_03_OrigYPos:Number;
		
		private var _delayTimerShakePieces:Timer;
		private var _delayTimerLightningBolts:Timer;
		
		private var _selectedGamePieceCurrentFrameLabel:String;
		
		private var _lightningSprite01:Sprite;
		private var _lightningSprite02:Sprite;
		private var _lightningSprite03:Sprite;
		private var _lightningBolt01:LightningBolt;
		private var _lightningBolt02:LightningBolt;
		private var _lightningBolt03:LightningBolt;
		
		private var _container_mc:Sprite;
		
		private var _gameBoard_mc:GameBoard;
		
		private var _boardHitArea_01_mc:BoardHitArea;
		private var _boardHitArea_02_mc:BoardHitArea;
		private var _boardHitArea_03_mc:BoardHitArea;
		private var _boardHitArea_04_mc:BoardHitArea;
		private var _boardHitArea_05_mc:BoardHitArea;
		private var _boardHitArea_06_mc:BoardHitArea;
		private var _boardHitArea_07_mc:BoardHitArea;
		private var _boardHitArea_08_mc:BoardHitArea;
		private var _boardHitArea_09_mc:BoardHitArea;
		private var _boardHitArea_10_mc:BoardHitArea;
		private var _boardHitArea_11_mc:BoardHitArea;
		private var _boardHitArea_12_mc:BoardHitArea;
		private var _boardHitArea_13_mc:BoardHitArea;
		private var _boardHitArea_14_mc:BoardHitArea;
		private var _boardHitArea_15_mc:BoardHitArea;
		private var _boardHitArea_16_mc:BoardHitArea;
		private var _boardHitArea_17_mc:BoardHitArea;
		private var _boardHitArea_18_mc:BoardHitArea;
		private var _boardHitArea_19_mc:BoardHitArea;
		private var _boardHitArea_20_mc:BoardHitArea;
		private var _boardHitArea_21_mc:BoardHitArea;
		private var _boardHitArea_22_mc:BoardHitArea;
		private var _boardHitArea_23_mc:BoardHitArea;
		private var _boardHitArea_24_mc:BoardHitArea;
		private var _boardHitArea_25_mc:BoardHitArea;
		
		private var _boardHitAreaArray:Array;
		private var _invalidBoardHitAreaArray:Array;
		private var _gamePieceArray:Array;
		
		private var _gamePiece_01_mc:GamePiece;
		private var _gamePiece_02_mc:GamePiece;
		private var _gamePiece_03_mc:GamePiece;
		private var _gamePiece_04_mc:GamePiece;
		private var _gamePiece_05_mc:GamePiece;
		
		private var _stage:Stage;
		
		private var _selectedGamePiece:Object;
		private var _conflictingGamePiecesArray:Array;
		
		
		/**
		 * Constructor for the view to create an application container MovieClip, application background, gameboard, game pieces, etc.
		 */
		public function LaserNodesView (argModel:Model, argController:Controller, argContainer:Sprite, argTesting:Boolean)
		{
			super (argModel, argController);
			
			_isTestingMode = argTesting;
			
			_container_mc = argContainer;
			
			_stage = _container_mc.stage;
			
			addBackground();
			addBoardHitAreas();
			addGamePieces();
			addLightningBoltSprites();
			addSounds();
			
			addEventListeners();
			
			_gamePieceConstraintRectangle = new Rectangle(290, 155, 575 - _gamePiece_01_mc.width - _gamePiece_01_mc.width/4, 435 - _gamePiece_01_mc.height - _gamePiece_01_mc.height/4);
			
			update();
		}
		
		
		private function addBackground() : void
		{
			_gameBoard_mc = new GameBoard();
			_gameBoard_mc.gotoAndStop(1);
			_gameBoard_mc.x = (_stage.stageWidth - _gameBoard_mc.width)/2;
			_gameBoard_mc.y = (_stage.stageHeight - _gameBoard_mc.height)/2;
			_container_mc.addChild (_gameBoard_mc);
		}
		
		private function addBoardHitAreas() : void
		{
			_boardHitArea_01_mc = new BoardHitArea ();
			_boardHitArea_02_mc = new BoardHitArea ();
			_boardHitArea_03_mc = new BoardHitArea ();
			_boardHitArea_04_mc = new BoardHitArea ();
			_boardHitArea_05_mc = new BoardHitArea ();
			_boardHitArea_06_mc = new BoardHitArea ();
			_boardHitArea_07_mc = new BoardHitArea ();
			_boardHitArea_08_mc = new BoardHitArea ();
			_boardHitArea_09_mc = new BoardHitArea ();
			_boardHitArea_10_mc = new BoardHitArea ();
			_boardHitArea_11_mc = new BoardHitArea ();
			_boardHitArea_12_mc = new BoardHitArea ();
			_boardHitArea_13_mc = new BoardHitArea ();
			_boardHitArea_14_mc = new BoardHitArea ();
			_boardHitArea_15_mc = new BoardHitArea ();
			_boardHitArea_16_mc = new BoardHitArea ();
			_boardHitArea_17_mc = new BoardHitArea ();
			_boardHitArea_18_mc = new BoardHitArea ();
			_boardHitArea_19_mc = new BoardHitArea ();
			_boardHitArea_20_mc = new BoardHitArea ();
			_boardHitArea_21_mc = new BoardHitArea ();
			_boardHitArea_22_mc = new BoardHitArea ();
			_boardHitArea_23_mc = new BoardHitArea ();
			_boardHitArea_24_mc = new BoardHitArea ();
			_boardHitArea_25_mc = new BoardHitArea ();
			
			_boardHitAreaArray = new Array (_boardHitArea_01_mc, _boardHitArea_02_mc, _boardHitArea_03_mc, _boardHitArea_04_mc, _boardHitArea_05_mc,
				_boardHitArea_06_mc, _boardHitArea_07_mc, _boardHitArea_08_mc, _boardHitArea_09_mc, _boardHitArea_10_mc,
				_boardHitArea_11_mc, _boardHitArea_12_mc, _boardHitArea_13_mc, _boardHitArea_14_mc, _boardHitArea_15_mc,
				_boardHitArea_16_mc, _boardHitArea_17_mc, _boardHitArea_18_mc, _boardHitArea_19_mc, _boardHitArea_20_mc,
				_boardHitArea_21_mc, _boardHitArea_22_mc, _boardHitArea_23_mc, _boardHitArea_24_mc, _boardHitArea_25_mc);
			
			_invalidBoardHitAreaArray = new Array (_boardHitArea_08_mc, _boardHitArea_12_mc, _boardHitArea_14_mc, _boardHitArea_18_mc);
			
			var BOARD_HIT_AREA_WIDTH = _boardHitArea_01_mc.width;
			var BOARD_HIT_AREA_HEIGHT = _boardHitArea_01_mc.height;
			
			var COLUMN_01_X_POS = BOARD_HIT_AREA_ORIGIN_X;
			var COLUMN_02_X_POS = BOARD_HIT_AREA_ORIGIN_X + (1 * BOARD_HIT_AREA_WIDTH) + (1 * BOARD_HIT_AREA_SPACING);
			var COLUMN_03_X_POS = BOARD_HIT_AREA_ORIGIN_X + (2 * BOARD_HIT_AREA_WIDTH) + (2 * BOARD_HIT_AREA_SPACING);
			var COLUMN_04_X_POS = BOARD_HIT_AREA_ORIGIN_X + (3 * BOARD_HIT_AREA_WIDTH) + (3 * BOARD_HIT_AREA_SPACING);
			var COLUMN_05_X_POS = BOARD_HIT_AREA_ORIGIN_X + (4 * BOARD_HIT_AREA_WIDTH) + (4 * BOARD_HIT_AREA_SPACING);
			
			var ROW_01_Y_POS = BOARD_HIT_AREA_ORIGIN_Y;
			var ROW_02_Y_POS = BOARD_HIT_AREA_ORIGIN_Y + (1 * BOARD_HIT_AREA_HEIGHT) + (1 * BOARD_HIT_AREA_SPACING);
			var ROW_03_Y_POS = BOARD_HIT_AREA_ORIGIN_Y + (2 * BOARD_HIT_AREA_HEIGHT) + (2 * BOARD_HIT_AREA_SPACING);
			var ROW_04_Y_POS = BOARD_HIT_AREA_ORIGIN_Y + (3 * BOARD_HIT_AREA_HEIGHT) + (3 * BOARD_HIT_AREA_SPACING);
			var ROW_05_Y_POS = BOARD_HIT_AREA_ORIGIN_Y + (4 * BOARD_HIT_AREA_HEIGHT) + (4 * BOARD_HIT_AREA_SPACING);
			
			// 1ST ROW
			_boardHitArea_01_mc.x = COLUMN_01_X_POS;
			_boardHitArea_02_mc.x = COLUMN_02_X_POS;
			_boardHitArea_03_mc.x = COLUMN_03_X_POS;
			_boardHitArea_04_mc.x = COLUMN_04_X_POS;
			_boardHitArea_05_mc.x = COLUMN_05_X_POS;
			
			_boardHitArea_01_mc.y = ROW_01_Y_POS;
			_boardHitArea_02_mc.y = ROW_01_Y_POS;
			_boardHitArea_03_mc.y = ROW_01_Y_POS;
			_boardHitArea_04_mc.y = ROW_01_Y_POS;
			_boardHitArea_05_mc.y = ROW_01_Y_POS;
			
			_boardHitArea_01_mc.visible = false;
			_boardHitArea_02_mc.visible = false;
			_boardHitArea_03_mc.visible = false;
			_boardHitArea_04_mc.visible = false;
			_boardHitArea_05_mc.visible = false;
			
			// 2ND ROW
			_boardHitArea_06_mc.x = COLUMN_01_X_POS;
			_boardHitArea_07_mc.x = COLUMN_02_X_POS;
			_boardHitArea_08_mc.x = COLUMN_03_X_POS;
			_boardHitArea_09_mc.x = COLUMN_04_X_POS;
			_boardHitArea_10_mc.x = COLUMN_05_X_POS;
			
			_boardHitArea_06_mc.y = ROW_02_Y_POS;
			_boardHitArea_07_mc.y = ROW_02_Y_POS;
			_boardHitArea_08_mc.y = ROW_02_Y_POS;
			_boardHitArea_09_mc.y = ROW_02_Y_POS;
			_boardHitArea_10_mc.y = ROW_02_Y_POS;
			
			_boardHitArea_06_mc.visible = false;
			_boardHitArea_07_mc.visible = false;
			_boardHitArea_08_mc.visible = false;
			_boardHitArea_09_mc.visible = false;
			_boardHitArea_10_mc.visible = false;
			
			// 3RD ROW
			_boardHitArea_11_mc.x = COLUMN_01_X_POS;
			_boardHitArea_12_mc.x = COLUMN_02_X_POS;
			_boardHitArea_13_mc.x = COLUMN_03_X_POS;
			_boardHitArea_14_mc.x = COLUMN_04_X_POS;
			_boardHitArea_15_mc.x = COLUMN_05_X_POS;
			
			_boardHitArea_11_mc.y = ROW_03_Y_POS;
			_boardHitArea_12_mc.y = ROW_03_Y_POS;
			_boardHitArea_13_mc.y = ROW_03_Y_POS;
			_boardHitArea_14_mc.y = ROW_03_Y_POS;
			_boardHitArea_15_mc.y = ROW_03_Y_POS;
			
			_boardHitArea_11_mc.visible = false;
			_boardHitArea_12_mc.visible = false;
			_boardHitArea_13_mc.visible = false;
			_boardHitArea_14_mc.visible = false;
			_boardHitArea_15_mc.visible = false;
			
			// 4TH ROW
			
			_boardHitArea_16_mc.x = COLUMN_01_X_POS;
			_boardHitArea_17_mc.x = COLUMN_02_X_POS;
			_boardHitArea_18_mc.x = COLUMN_03_X_POS;
			_boardHitArea_19_mc.x = COLUMN_04_X_POS;
			_boardHitArea_20_mc.x = COLUMN_05_X_POS;
			
			_boardHitArea_16_mc.y = ROW_04_Y_POS;
			_boardHitArea_17_mc.y = ROW_04_Y_POS;
			_boardHitArea_18_mc.y = ROW_04_Y_POS;
			_boardHitArea_19_mc.y = ROW_04_Y_POS;
			_boardHitArea_20_mc.y = ROW_04_Y_POS;
			
			_boardHitArea_16_mc.visible = false;
			_boardHitArea_17_mc.visible = false;
			_boardHitArea_18_mc.visible = false;
			_boardHitArea_19_mc.visible = false;
			_boardHitArea_20_mc.visible = false;
			
			// 5TH ROW
			
			_boardHitArea_21_mc.x = COLUMN_01_X_POS;
			_boardHitArea_22_mc.x = COLUMN_02_X_POS;
			_boardHitArea_23_mc.x = COLUMN_03_X_POS;
			_boardHitArea_24_mc.x = COLUMN_04_X_POS;
			_boardHitArea_25_mc.x = COLUMN_05_X_POS;
			
			_boardHitArea_21_mc.y = ROW_05_Y_POS;
			_boardHitArea_22_mc.y = ROW_05_Y_POS;
			_boardHitArea_23_mc.y = ROW_05_Y_POS;
			_boardHitArea_24_mc.y = ROW_05_Y_POS;
			_boardHitArea_25_mc.y = ROW_05_Y_POS;
			
			_boardHitArea_21_mc.visible = false;
			_boardHitArea_22_mc.visible = false;
			_boardHitArea_23_mc.visible = false;
			_boardHitArea_24_mc.visible = false;
			_boardHitArea_25_mc.visible = false;
			
			_container_mc.addChild(_boardHitArea_01_mc);
			_container_mc.addChild(_boardHitArea_02_mc);
			_container_mc.addChild(_boardHitArea_03_mc);
			_container_mc.addChild(_boardHitArea_04_mc);
			_container_mc.addChild(_boardHitArea_05_mc);
			
			_container_mc.addChild(_boardHitArea_06_mc);
			_container_mc.addChild(_boardHitArea_07_mc);
			_container_mc.addChild(_boardHitArea_08_mc);
			_container_mc.addChild(_boardHitArea_09_mc);
			_container_mc.addChild(_boardHitArea_10_mc);
			
			_container_mc.addChild(_boardHitArea_11_mc);
			_container_mc.addChild(_boardHitArea_12_mc);
			_container_mc.addChild(_boardHitArea_13_mc);
			_container_mc.addChild(_boardHitArea_14_mc);
			_container_mc.addChild(_boardHitArea_15_mc);
			
			_container_mc.addChild(_boardHitArea_16_mc);
			_container_mc.addChild(_boardHitArea_17_mc);
			_container_mc.addChild(_boardHitArea_18_mc);
			_container_mc.addChild(_boardHitArea_19_mc);
			_container_mc.addChild(_boardHitArea_20_mc);
			
			_container_mc.addChild(_boardHitArea_21_mc);
			_container_mc.addChild(_boardHitArea_22_mc);
			_container_mc.addChild(_boardHitArea_23_mc);
			_container_mc.addChild(_boardHitArea_24_mc);
			_container_mc.addChild(_boardHitArea_25_mc);
		}
		
		private function addGamePieces () : void
		{
			_gamePiece_01_mc = new GamePiece ();
			_gamePiece_02_mc = new GamePiece ();
			_gamePiece_03_mc = new GamePiece ();
			_gamePiece_04_mc = new GamePiece ();
			_gamePiece_05_mc = new GamePiece ();
			
			_gamePieceArray = new Array (_gamePiece_01_mc, _gamePiece_02_mc, _gamePiece_03_mc, _gamePiece_04_mc, _gamePiece_05_mc);
			
			var GAME_PIECE_WIDTH = _gamePiece_01_mc.width;
			var GAME_PIECE_HEIGHT = _gamePiece_01_mc.height;
			
			GAME_PIECE_01_HOME_Y_POS = GAME_PIECES_HOME_ORIGIN_Y;
			GAME_PIECE_02_HOME_Y_POS = GAME_PIECES_HOME_ORIGIN_Y + (1 * (GAME_PIECE_HEIGHT + GAME_PIECE_HOME_POSITION_SPACING));
			GAME_PIECE_03_HOME_Y_POS = GAME_PIECES_HOME_ORIGIN_Y + (2 * (GAME_PIECE_HEIGHT + GAME_PIECE_HOME_POSITION_SPACING));
			GAME_PIECE_04_HOME_Y_POS = GAME_PIECES_HOME_ORIGIN_Y + (3 * (GAME_PIECE_HEIGHT + GAME_PIECE_HOME_POSITION_SPACING));
			GAME_PIECE_05_HOME_Y_POS = GAME_PIECES_HOME_ORIGIN_Y + (4 * (GAME_PIECE_HEIGHT + GAME_PIECE_HOME_POSITION_SPACING));
			
			_gamePiece_01_mc.x = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_01_mc.y = GAME_PIECE_01_HOME_Y_POS;
			
			_gamePiece_02_mc.x = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_02_mc.y = GAME_PIECE_02_HOME_Y_POS;
			
			_gamePiece_03_mc.x = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_03_mc.y = GAME_PIECE_03_HOME_Y_POS;
			
			_gamePiece_04_mc.x = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_04_mc.y = GAME_PIECE_04_HOME_Y_POS;
			
			_gamePiece_05_mc.x = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_05_mc.y = GAME_PIECE_05_HOME_Y_POS;
			
			_gamePiece_01_mc.buttonMode = true;
			_gamePiece_02_mc.buttonMode = true;
			_gamePiece_03_mc.buttonMode = true;
			_gamePiece_04_mc.buttonMode = true;
			_gamePiece_05_mc.buttonMode = true;
			
			_gamePiece_01_mc.homeXPosition = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_02_mc.homeXPosition = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_03_mc.homeXPosition = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_04_mc.homeXPosition = GAME_PIECES_HOME_ORIGIN_X;
			_gamePiece_05_mc.homeXPosition = GAME_PIECES_HOME_ORIGIN_X;
			
			_gamePiece_01_mc.homeYPosition = GAME_PIECE_01_HOME_Y_POS;
			_gamePiece_02_mc.homeYPosition = GAME_PIECE_02_HOME_Y_POS;
			_gamePiece_03_mc.homeYPosition = GAME_PIECE_03_HOME_Y_POS;
			_gamePiece_04_mc.homeYPosition = GAME_PIECE_04_HOME_Y_POS;
			_gamePiece_05_mc.homeYPosition = GAME_PIECE_05_HOME_Y_POS;
			
			_gamePiece_01_mc.gotoAndStop("no_glow");
			_gamePiece_02_mc.gotoAndStop("no_glow");
			_gamePiece_03_mc.gotoAndStop("no_glow");
			_gamePiece_04_mc.gotoAndStop("no_glow");
			_gamePiece_05_mc.gotoAndStop("no_glow");
			
			_gamePiece_01_mc.width = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_02_mc.width = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_03_mc.width = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_04_mc.width = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_05_mc.width = GAME_PIECE_HOME_POSITION_DIMENSION;
			
			_gamePiece_01_mc.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_02_mc.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_03_mc.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_04_mc.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			_gamePiece_05_mc.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			
			_gamePiece_01_mc.name = "_gamePiece_01_mc";
			_gamePiece_02_mc.name = "_gamePiece_02_mc";
			_gamePiece_03_mc.name = "_gamePiece_03_mc";
			_gamePiece_04_mc.name = "_gamePiece_04_mc";
			_gamePiece_05_mc.name = "_gamePiece_05_mc";
			
			_container_mc.addChild (_gamePiece_01_mc);
			_container_mc.addChild (_gamePiece_02_mc);
			_container_mc.addChild (_gamePiece_03_mc);
			_container_mc.addChild (_gamePiece_04_mc);
			_container_mc.addChild (_gamePiece_05_mc);
		}
		
		private function addLightningBoltSprites() : void
		{
			_lightningSprite01 = new Sprite();
			_lightningSprite02 = new Sprite();
			_lightningSprite03 = new Sprite();
			
			_container_mc.addChild(_lightningSprite01);
			_container_mc.addChild(_lightningSprite02);
			_container_mc.addChild(_lightningSprite03);
		}
		
		private function addSounds() : void
		{
			if (_isTestingMode == true)
			{
				Globals.vars["assetsUrl"] = "./";
			}

			_gamePieceMouseDown_snd = new Sound();
			_gamePieceMouseDown_snd.load(new URLRequest(Globals.vars["assetsUrl"] + SFX_DIRECTORY + "gamePieceMouseDown" + ".mp3"));
			
			_gamePieceMouseUp_snd = new Sound();
			_gamePieceMouseUp_snd.load(new URLRequest(Globals.vars["assetsUrl"] + SFX_DIRECTORY +  "gamePieceMouseUp" + ".mp3"));
			
			_powerLevel_00_Hum_snd = new PowerLevel00HumMP3();
			
			_powerLevel_01_Hum_snd = new PowerLevel01HumMP3();
			
			_powerLevel_02_Hum_snd = new PowerLevel02HumMP3();
			
			_powerLevel_03_Hum_snd = new PowerLevel03HumMP3();
			
			_powerLevel_04_Hum_snd = new PowerLevel04HumMP3();
			
			_powerLevel_05_Hum_snd = new PowerLevel05HumMP3();
			
			_powerLevel_06_Hum_snd = new PowerLevel06HumMP3();
			
			_lightning_snd = new Sound();
			_lightning_snd.load(new URLRequest(Globals.vars["assetsUrl"] + SFX_DIRECTORY +  "lightning" + ".mp3"));
			
			_gamePieceMouseDown_stf = new SoundTransform(GAME_PIECE_MOUSE_DOWN_VOLUME, 0); 
			_gamePieceMouseUp_stf = new SoundTransform(GAME_PIECE_MOUSE_UP_VOLUME, 0);
			_lightning_stf = new SoundTransform(LIGHTNING_VOLUME, 0); 
			_powerLevel_00_Hum_stf = new SoundTransform(POWER_LEVEL_00_HUM_VOLUME, 0); 
			_powerLevel_01_Hum_stf = new SoundTransform(POWER_LEVEL_01_HUM_VOLUME, 0); 
			_powerLevel_02_Hum_stf = new SoundTransform(POWER_LEVEL_02_HUM_VOLUME, 0); 
			_powerLevel_03_Hum_stf = new SoundTransform(POWER_LEVEL_03_HUM_VOLUME, 0); 
			_powerLevel_04_Hum_stf = new SoundTransform(POWER_LEVEL_04_HUM_VOLUME, 0); 
			_powerLevel_05_Hum_stf = new SoundTransform(POWER_LEVEL_05_HUM_VOLUME, 0);  
			_powerLevel_06_Hum_stf = new SoundTransform(POWER_LEVEL_06_HUM_VOLUME, 0);
			
		}
		
		private function gamePiece_onMouseRollOverEventHandler(event:MouseEvent) : void{
			if (controller.getIsGamePiecesWaitingForLightningBolts() == false)
			{
				event.currentTarget.buttonMode = true;
			} else {
				event.currentTarget.buttonMode = false;
			}
		}
		
		private function gamePiece_onMouseDownEventHandler(event:MouseEvent) : void
		{
			if (controller.getIsGamePiecesWaitingForLightningBolts() == false && controller.getPowerLevel() < 5)
			{
				_selectedGamePiece = event.currentTarget;
				
				_selectedGamePiece.gotoAndStop("no_glow");
				
				_selectedGamePiece.removeEventListener(MouseEvent.MOUSE_DOWN, gamePiece_onMouseDownEventHandler);
				
				_container_mc.setChildIndex(DisplayObject(event.currentTarget), _container_mc.numChildren - 1);
				
				_selectedGamePieceCurrentFrameLabel = _selectedGamePiece.currentLabel;
				
				_gamePieceMouseDown_snd.play(0, 1, _gamePieceMouseDown_stf);
				
				_stage.addEventListener(MouseEvent.MOUSE_UP, dropGamePiece);
				
				_selectedGamePiece.startDrag(true, _gamePieceConstraintRectangle);
				
				_selectedGamePiece.gotoAndStop("no_glow");
				_selectedGamePiece.width = GAME_PIECE_DRAG_DIMENSION;				
				_selectedGamePiece.height = GAME_PIECE_DRAG_DIMENSION;
			}
		}
		
		private function dropGamePiece(event:MouseEvent) : void {
			
			_stage.removeEventListener(MouseEvent.MOUSE_UP, dropGamePiece);
			
			_selectedGamePiece.addEventListener(MouseEvent.MOUSE_DOWN, gamePiece_onMouseDownEventHandler);
			
			_selectedGamePiece.stopDrag();
			
			_gamePieceMouseUp_snd.play(0, 1, _gamePieceMouseUp_stf);

			controller.moveSelectedGamePiece(_selectedGamePiece, _invalidBoardHitAreaArray, _boardHitAreaArray);
			
		}
		
		private function returnSelectedGamePieceToHomePosition(event:GamePieceEvent) : void
		{			
			var _selectedGamePiece:Object = event.ParamsObject.selectedGamePiece;
			
			_selectedGamePiece.gotoAndStop("no_glow");
			_selectedGamePiece.width = GAME_PIECE_HOME_POSITION_DIMENSION;				
			_selectedGamePiece.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			
			updatePowerLevelGraphics();
			
			TweenLite.to(_selectedGamePiece, 0.7 ,{x:_selectedGamePiece.homeXPosition, y:_selectedGamePiece.homeYPosition, ease:Elastic.easeOut});
		}
		
		private function returnConflictingGamePieceToHomePosition(event:GamePieceEvent) : void
		{
			var conflictingGamePiece:Object = event.ParamsObject.conflictingGamePiece;
			
			conflictingGamePiece.gotoAndStop("no_glow");
			conflictingGamePiece.width = GAME_PIECE_HOME_POSITION_DIMENSION;				
			conflictingGamePiece.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			
			updatePowerLevelGraphics();
			
			TweenLite.to(conflictingGamePiece, 0.7 ,{x:conflictingGamePiece.homeXPosition, y:conflictingGamePiece.homeYPosition, ease:Elastic.easeOut});	
		}
		
		private function returnSelectedAndConflictingGamePiecesToHomePositionWithLightning(event:GamePieceEvent) : void
		{
			shakeSelectedAndConflictingGamePieces(event);
		}
		
		private function returnAllGamePiecesToHomePosition(event:GamePieceEvent) : void
		{
			for (var i:uint = 0; i < _gamePieceArray.length; i++)
			{
				_gamePieceArray[i].gotoAndStop("no_glow");
				_gamePieceArray[i].width = GAME_PIECE_HOME_POSITION_DIMENSION;				
				_gamePieceArray[i].height = GAME_PIECE_HOME_POSITION_DIMENSION;
				
				updatePowerLevelGraphics();
				
				TweenLite.to(_gamePieceArray[i], 0.7 ,{x:_gamePieceArray[i].homeXPosition, y:_gamePieceArray[i].homeYPosition, ease:Elastic.easeOut});	
			}
			
		}
		
		private function shakeSelectedAndConflictingGamePieces(event:GamePieceEvent) : void
		{	
			
			var _selectedGamePiece:Object = controller.getSelectedGamePiece();
			var _conflictingGamePiecesArray:Array = controller.getConflictingGamePiecesArray();
			
			_selectedGamePieceOrigXPos = _selectedGamePiece.x;
			_selectedGamePieceOrigYPos = _selectedGamePiece.y;
			
			if (_conflictingGamePiecesArray.length == 1)
			{
				_conflictingGamePiece_01_OrigXPos = _conflictingGamePiecesArray[0].x;
				_conflictingGamePiece_01_OrigYPos = _conflictingGamePiecesArray[0].y;
			}
			
			if (_conflictingGamePiecesArray.length == 2)
			{
				_conflictingGamePiece_01_OrigXPos = _conflictingGamePiecesArray[0].x;
				_conflictingGamePiece_01_OrigYPos = _conflictingGamePiecesArray[0].y;
				
				_conflictingGamePiece_02_OrigXPos = _conflictingGamePiecesArray[1].x;
				_conflictingGamePiece_02_OrigYPos = _conflictingGamePiecesArray[1].y;	
			}
			
			if (_conflictingGamePiecesArray.length == 3)
			{
				_conflictingGamePiece_01_OrigXPos = _conflictingGamePiecesArray[0].x;
				_conflictingGamePiece_01_OrigYPos = _conflictingGamePiecesArray[0].y;
				
				_conflictingGamePiece_02_OrigXPos = _conflictingGamePiecesArray[1].x;
				_conflictingGamePiece_02_OrigYPos = _conflictingGamePiecesArray[1].y;	
				
				_conflictingGamePiece_03_OrigXPos = _conflictingGamePiecesArray[2].x;
				_conflictingGamePiece_03_OrigYPos = _conflictingGamePiecesArray[2].y;	
			}
						
			_delayTimerShakePieces = new Timer(.5, 99999);
			_delayTimerShakePieces.addEventListener(TimerEvent.TIMER, startShakingSelectedAndConflictingGamePieces);
			_delayTimerShakePieces.start();
		}
		
		private function startShakingSelectedAndConflictingGamePieces(event:TimerEvent) : void
		{	
			
			var _selectedGamePiece:Object = controller.getSelectedGamePiece();
			var _conflictingGamePiecesArray:Array = controller.getConflictingGamePiecesArray();
			
			_selectedGamePiece.x = _selectedGamePieceOrigXPos + Math.floor(Math.random()*3) - 1; 
			_selectedGamePiece.y = _selectedGamePieceOrigYPos + Math.floor(Math.random()*3) - 1;
			
			if (_conflictingGamePiecesArray.length == 1)
			{
				_conflictingGamePiecesArray[0].x = _conflictingGamePiece_01_OrigXPos + Math.floor(Math.random()*3) - 1; 
				_conflictingGamePiecesArray[0].y = _conflictingGamePiece_01_OrigYPos + Math.floor(Math.random()*3) - 1;	
			}
			
			if (_conflictingGamePiecesArray.length == 2)
			{
				_conflictingGamePiecesArray[0].x = _conflictingGamePiece_01_OrigXPos + Math.floor(Math.random()*3) - 1; 
				_conflictingGamePiecesArray[0].y = _conflictingGamePiece_01_OrigYPos + Math.floor(Math.random()*3) - 1;
				
				_conflictingGamePiecesArray[1].x = _conflictingGamePiece_02_OrigXPos + Math.floor(Math.random()*3) - 1; 
				_conflictingGamePiecesArray[1].y = _conflictingGamePiece_02_OrigYPos + Math.floor(Math.random()*3) - 1;	
			}
			
			if (_conflictingGamePiecesArray.length == 3)
			{
				_conflictingGamePiecesArray[0].x = _conflictingGamePiece_01_OrigXPos + Math.floor(Math.random()*3) - 1; 
				_conflictingGamePiecesArray[0].y = _conflictingGamePiece_01_OrigYPos + Math.floor(Math.random()*3) - 1;
				
				_conflictingGamePiecesArray[1].x = _conflictingGamePiece_02_OrigXPos + Math.floor(Math.random()*3) - 1; 
				_conflictingGamePiecesArray[1].y = _conflictingGamePiece_02_OrigYPos + Math.floor(Math.random()*3) - 1;
				
				_conflictingGamePiecesArray[2].x = _conflictingGamePiece_03_OrigXPos + Math.floor(Math.random()*3) - 1; 
				_conflictingGamePiecesArray[2].y = _conflictingGamePiece_03_OrigYPos + Math.floor(Math.random()*3) - 1;	
			}
			
			if (_delayTimerShakePieces.currentCount == 16)
			{				
				displayLightningBolts();
				delayLightning(1);
			} 
		}
		
		private function displayLightningBolts()
		{
			
			var _selectedGamePiece:Object = controller.getSelectedGamePiece();
			var _conflictingGamePiecesArray:Array = controller.getConflictingGamePiecesArray();
			
			_lightningSprite01 = new Sprite();
			_lightningSprite02 = new Sprite();
			_lightningSprite03 = new Sprite();
			
			_container_mc.addChild(_lightningSprite01);
			_container_mc.addChild(_lightningSprite02);
			_container_mc.addChild(_lightningSprite03);
			
			for (var i:uint = 0; i < _conflictingGamePiecesArray.length; i++)
			{
				if (i == 0){
					_lightningBolt01 = new LightningBolt(_lightningSprite01, _selectedGamePiece.x, _selectedGamePiece.y, _conflictingGamePiecesArray[i].x, _conflictingGamePiecesArray[i].y); 	
				}
				if (i == 1){
					_lightningBolt02 = new LightningBolt(_lightningSprite02, _selectedGamePiece.x, _selectedGamePiece.y, _conflictingGamePiecesArray[i].x, _conflictingGamePiecesArray[i].y); 	
				}
				if (i == 2){
					_lightningBolt03 = new LightningBolt(_lightningSprite03, _selectedGamePiece.x, _selectedGamePiece.y, _conflictingGamePiecesArray[i].x, _conflictingGamePiecesArray[i].y); 	
				}
			}
			
			_lightning_snd.play(0, 1, _lightning_stf);
		}
		
		private function delayLightning(repeatCount:Number) : void
		{
			_delayTimerLightningBolts = new Timer(_lightning_snd.length, repeatCount);
			_delayTimerLightningBolts.addEventListener(TimerEvent.TIMER_COMPLETE, killLightningBoltsAndReturnSelectedAndConflictingGamePiecesToHomePosition);
			_delayTimerLightningBolts.start();
		}
		
		private function killLightningBoltsAndReturnSelectedAndConflictingGamePiecesToHomePosition(event:TimerEvent) : void
		{
			
			var _selectedGamePiece:Object = controller.getSelectedGamePiece();
			var _conflictingGamePiecesArray:Array = controller.getConflictingGamePiecesArray();
			
			_delayTimerShakePieces.stop();
			_delayTimerShakePieces = null;
			
			_delayTimerLightningBolts.stop();
			_delayTimerLightningBolts = null;
			
			_lightningSprite01.graphics.clear();
			_lightningSprite02.graphics.clear();
			_lightningSprite03.graphics.clear();
			
			_container_mc.removeChild(_lightningSprite01);
			_container_mc.removeChild(_lightningSprite02);
			_container_mc.removeChild(_lightningSprite03);
			
			_lightningSprite01 =  null;
			_lightningSprite02 =  null;
			_lightningSprite03 =  null;
			
			controller.setIsGamePiecesWaitingForLightningBolts(false);
			
			_selectedGamePiece.gotoAndStop("no_glow");
			_selectedGamePiece.width = GAME_PIECE_HOME_POSITION_DIMENSION;				
			_selectedGamePiece.height = GAME_PIECE_HOME_POSITION_DIMENSION;
			
			updatePowerLevelGraphics();
			
			TweenLite.to(_selectedGamePiece, 0.7 ,{x:_selectedGamePiece.homeXPosition, y:_selectedGamePiece.homeYPosition, ease:Elastic.easeOut});
			
			for (var j:uint = 0; j < _conflictingGamePiecesArray.length; j++)
			{
				_conflictingGamePiecesArray[j].gotoAndStop("no_glow");
				_conflictingGamePiecesArray[j].width = GAME_PIECE_HOME_POSITION_DIMENSION;				
				_conflictingGamePiecesArray[j].height = GAME_PIECE_HOME_POSITION_DIMENSION;
				TweenLite.to(_conflictingGamePiecesArray[j], 0.7 ,{x:_conflictingGamePiecesArray[j].homeXPosition, y:_conflictingGamePiecesArray[j].homeYPosition, ease:Elastic.easeOut});		
			}
		}
		
		private function placeSelectedGamePieceOnBoard(event:GamePieceEvent) : void
		{			
			var currentGamePiece:Object = event.ParamsObject.selectedGamePiece;
			var currentHitArea:Object = event.ParamsObject.hitArea;
			
			currentGamePiece.x = currentHitArea.x + currentHitArea.width/2;
			currentGamePiece.y = currentHitArea.y + currentHitArea.height/2;
			
			currentGamePiece.gotoAndStop("glow");
			currentGamePiece.width = GAME_PIECE_ON_BOARD_DIMENSION;				
			currentGamePiece.height = GAME_PIECE_ON_BOARD_DIMENSION;
			
			updatePowerLevelGraphics();			
		}
		
		private function addEventListeners() : void
		{
			model.addEventListener(GamePieceEvent.PLACE_SELECTED_GAME_PIECE_ON_BOARD, placeSelectedGamePieceOnBoard);
			model.addEventListener(GamePieceEvent.RETURN_SELECTED_GAME_PIECE_TO_HOME_POSITION, returnSelectedGamePieceToHomePosition);
			model.addEventListener(GamePieceEvent.RETURN_CONFLICTING_GAME_PIECE_TO_HOME_POSITION, returnConflictingGamePieceToHomePosition);
			model.addEventListener(GamePieceEvent.RETURN_SELECTED_AND_CONFLICTING_GAME_PIECES_TO_HOME_POSITION_WITH_LIGHTNING, returnSelectedAndConflictingGamePiecesToHomePositionWithLightning);
			model.addEventListener(GamePieceEvent.RETURN_ALL_GAME_PIECES_TO_HOME_POSITION, returnAllGamePiecesToHomePosition);
			
			_gamePiece_01_mc.addEventListener(MouseEvent.MOUSE_DOWN, gamePiece_onMouseDownEventHandler);
			_gamePiece_02_mc.addEventListener(MouseEvent.MOUSE_DOWN, gamePiece_onMouseDownEventHandler);
			_gamePiece_03_mc.addEventListener(MouseEvent.MOUSE_DOWN, gamePiece_onMouseDownEventHandler);
			_gamePiece_04_mc.addEventListener(MouseEvent.MOUSE_DOWN, gamePiece_onMouseDownEventHandler);
			_gamePiece_05_mc.addEventListener(MouseEvent.MOUSE_DOWN, gamePiece_onMouseDownEventHandler);
			
			_gamePiece_01_mc.addEventListener(MouseEvent.ROLL_OVER, gamePiece_onMouseRollOverEventHandler);
			_gamePiece_02_mc.addEventListener(MouseEvent.ROLL_OVER, gamePiece_onMouseRollOverEventHandler);
			_gamePiece_03_mc.addEventListener(MouseEvent.ROLL_OVER, gamePiece_onMouseRollOverEventHandler);
			_gamePiece_04_mc.addEventListener(MouseEvent.ROLL_OVER, gamePiece_onMouseRollOverEventHandler);
			_gamePiece_05_mc.addEventListener(MouseEvent.ROLL_OVER, gamePiece_onMouseRollOverEventHandler);
				
		}
		
		private function updatePowerLevelGraphics() : void
		{
			if (controller.getIsGamePiecesWaitingForLightningBolts() == false)
			{
				var powerLevel:Number = controller.getPowerLevel();

				if (powerLevel == 0 && _isPlayingPowerLevel00GameBoardAnimation == false)
				{	
					MovieClip(_gameBoard_mc).gotoAndPlay("powerLevel_00");
					
					//_powerLevel_00_Hum_sch = _powerLevel_00_Hum_snd.play(0, 99999, _powerLevel_00_Hum_stf);
					
					_isPlayingPowerLevel00GameBoardAnimation = true;
					_isPlayingPowerLevel01GameBoardAnimation = false;
					_isPlayingPowerLevel02GameBoardAnimation = false;
					_isPlayingPowerLevel03GameBoardAnimation = false;
					_isPlayingPowerLevel04GameBoardAnimation = false;
					_isPlayingPowerLevel05GameBoardAnimation = false;
				}
				
				if (powerLevel == 1 && _isPlayingPowerLevel01GameBoardAnimation == false)
				{	
					MovieClip(_gameBoard_mc).gotoAndPlay("powerLevel_01");
					
					_powerLevel_01_Hum_sch = _powerLevel_01_Hum_snd.play(0, 99999, _powerLevel_01_Hum_stf);
					
					_isPlayingPowerLevel00GameBoardAnimation = false;
					_isPlayingPowerLevel01GameBoardAnimation = true;
					_isPlayingPowerLevel02GameBoardAnimation = false;
					_isPlayingPowerLevel03GameBoardAnimation = false;
					_isPlayingPowerLevel04GameBoardAnimation = false;
					_isPlayingPowerLevel05GameBoardAnimation = false;
				}
				
				if (powerLevel == 2 && _isPlayingPowerLevel02GameBoardAnimation == false)
				{	
					MovieClip(_gameBoard_mc).gotoAndPlay("powerLevel_02");
					
					_powerLevel_02_Hum_sch = _powerLevel_02_Hum_snd.play(0, 99999, _powerLevel_02_Hum_stf);
					
					_isPlayingPowerLevel00GameBoardAnimation = false;
					_isPlayingPowerLevel01GameBoardAnimation = false;
					_isPlayingPowerLevel02GameBoardAnimation = true;
					_isPlayingPowerLevel03GameBoardAnimation = false;
					_isPlayingPowerLevel04GameBoardAnimation = false;
					_isPlayingPowerLevel05GameBoardAnimation = false;
				}
				
				if (powerLevel == 3 && _isPlayingPowerLevel03GameBoardAnimation == false)
				{	
					MovieClip(_gameBoard_mc).gotoAndPlay("powerLevel_03");
					
					_powerLevel_03_Hum_sch = _powerLevel_03_Hum_snd.play(0, 99999, _powerLevel_03_Hum_stf);
					
					_isPlayingPowerLevel00GameBoardAnimation = false;
					_isPlayingPowerLevel01GameBoardAnimation = false;
					_isPlayingPowerLevel02GameBoardAnimation = false;
					_isPlayingPowerLevel03GameBoardAnimation = true;
					_isPlayingPowerLevel04GameBoardAnimation = false;
					_isPlayingPowerLevel05GameBoardAnimation = false;
				}
				
				if (powerLevel == 4 && _isPlayingPowerLevel04GameBoardAnimation == false)
				{	
					MovieClip(_gameBoard_mc).gotoAndPlay("powerLevel_04");
					
					_powerLevel_04_Hum_sch = _powerLevel_04_Hum_snd.play(0, 99999, _powerLevel_04_Hum_stf);
					
					_isPlayingPowerLevel00GameBoardAnimation = false;
					_isPlayingPowerLevel01GameBoardAnimation = false;
					_isPlayingPowerLevel02GameBoardAnimation = false;
					_isPlayingPowerLevel03GameBoardAnimation = false;
					_isPlayingPowerLevel04GameBoardAnimation = true;
					_isPlayingPowerLevel05GameBoardAnimation = false;
				}
				
				if (powerLevel == 5 && _isPlayingPowerLevel05GameBoardAnimation == false)
				{	
					MovieClip(_gameBoard_mc).gotoAndPlay("powerLevel_05");
					
					_powerLevel_05_Hum_sch = _powerLevel_05_Hum_snd.play(0, 99999, _powerLevel_05_Hum_stf);
					
					_isPlayingPowerLevel00GameBoardAnimation = false;
					_isPlayingPowerLevel01GameBoardAnimation = false;
					_isPlayingPowerLevel02GameBoardAnimation = false;
					_isPlayingPowerLevel03GameBoardAnimation = false;
					_isPlayingPowerLevel04GameBoardAnimation = false;
					_isPlayingPowerLevel05GameBoardAnimation = true;
					
					startPowerLevel05Timer();
				}
				
				if (_powerLevel_00_Hum_sch && _isPlayingPowerLevel00GameBoardAnimation == false)
				{
					_powerLevel_00_Hum_sch.stop();
				}
				
				if (_powerLevel_01_Hum_sch && _isPlayingPowerLevel01GameBoardAnimation == false)
				{
					_powerLevel_01_Hum_sch.stop();	
				}
				
				if (_powerLevel_02_Hum_sch && _isPlayingPowerLevel02GameBoardAnimation == false)
				{
					_powerLevel_02_Hum_sch.stop();	
				}
				
				if (_powerLevel_03_Hum_sch && _isPlayingPowerLevel03GameBoardAnimation == false)
				{
					_powerLevel_03_Hum_sch.stop();	
				}
				
				if (_powerLevel_04_Hum_sch && _isPlayingPowerLevel04GameBoardAnimation == false)
				{
					_powerLevel_04_Hum_sch.stop();	
				}
				
				if (_powerLevel_05_Hum_sch && _isPlayingPowerLevel05GameBoardAnimation == false)
				{
					_powerLevel_05_Hum_sch.stop();	
				}
				
			}
		}
		
		private function startPowerLevel05Timer() : void
		{
			_powerLevel05Timer = new Timer(400, 5);
			_powerLevel05Timer.addEventListener(TimerEvent.TIMER_COMPLETE, startPowerLevel06Animation);
			_powerLevel05Timer.start();
		}
		
		private function startPowerLevel06Animation(event:TimerEvent) : void
		{
			trace("Start powerlvl06animation");
			
			_powerLevel_05_Hum_sch.stop();
			
			SolvedState();
			
			_powerLevel06Timer = new Timer(100, 7);
			_powerLevel06Timer.addEventListener(TimerEvent.TIMER_COMPLETE, gameSolved);
			_powerLevel06Timer.start();
		}
		
		public function SolvedState():void
		{						
			_powerLevel_06_Hum_sch = _powerLevel_06_Hum_snd.play(0, 99999, _powerLevel_06_Hum_stf);
			MovieClip(_gameBoard_mc).gotoAndPlay("powerLevel_06");
			
			_gamePiece_01_mc.mouseEnabled = false;
			_gamePiece_01_mc.mouseChildren = false;
			_gamePiece_02_mc.mouseEnabled = false;
			_gamePiece_02_mc.mouseChildren = false;
			_gamePiece_03_mc.mouseEnabled = false;
			_gamePiece_03_mc.mouseChildren = false;
			_gamePiece_04_mc.mouseEnabled = false;
			_gamePiece_04_mc.mouseChildren = false;
			_gamePiece_05_mc.mouseEnabled = false;
			_gamePiece_05_mc.mouseChildren = false;			
		}
		
		private function gameSolved(event:TimerEvent) : void
		{
			controller.gameSolved();
		}
		
		override public function update (event : Event = null)  :  void
		{		
			updatePowerLevelGraphics();
		}
		
	}
	
}