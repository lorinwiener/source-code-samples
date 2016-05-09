package com.fireball.laserNodes.events
{
	import flash.events.Event;
	
	public class GamePieceEvent extends Event
	{
		public static const PLACE_SELECTED_GAME_PIECE_ON_BOARD:String = "PLACE_SELECTED_GAME_PIECE_ON_BOARD";
		public static const RETURN_SELECTED_GAME_PIECE_TO_HOME_POSITION:String = "RETURN_SELECTED_GAME_PIECE_TO_HOME_POSITION";
		public static const RETURN_CONFLICTING_GAME_PIECE_TO_HOME_POSITION:String = "RETURN_CONFLICTING_GAME_PIECE_TO_HOME_POSITION";
		public static const RETURN_SELECTED_AND_CONFLICTING_GAME_PIECES_TO_HOME_POSITION_WITH_LIGHTNING:String = "RETURN_SELECTED_AND_CONFLICTING_GAME_PIECES_TO_HOME_POSITION_WITH_LIGHTNING";
		public static const RETURN_ALL_GAME_PIECES_TO_HOME_POSITION:String = "RETURN_ALL_GAME_PIECES_TO_HOME_POSITION";
		public static const DISPLAY_LIGHTNING_BOLTS:String = "DISPLAY_LIGHTNING_BOLTS";
		
		
		private var paramsObject:Object;
		
		public function get ParamsObject():Object
		{
			return paramsObject;
		}
		
		public function GamePieceEvent(argType:String, argParamsObject:Object, argBubbles:Boolean=true, argCancelable:Boolean=false) : void
		{
			paramsObject = argParamsObject;
			
			super(argType, argBubbles, argCancelable);
			
		}
		
		override public function clone() : Event 
		{ 
			return new GamePieceEvent(type, this.paramsObject, bubbles, cancelable);
		} 
		
		override public function toString() : String 
		{ 
			return formatToString("GamePieceEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}