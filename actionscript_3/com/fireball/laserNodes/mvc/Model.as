﻿package com.fireball.laserNodes.mvc
{
			
	//--------------------------------------
	// IMPORTS
	//--------------------------------------
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	
	//--------------------------------------
	// CLASS
	//--------------------------------------
	/**
	 * Base model class for MVC architecture
	*/
	public class Model extends EventDispatcher
	{
		
		//--------------------------------------
		// PROPERTIES
		//--------------------------------------
		
		
		// CONSTANTS
		public static const MODEL_CHANGE:String = "modelChange";
		
		
		//--------------------------------------
		// CONSTRUCTOR
		//--------------------------------------
		public function Model ()
		{

		}
				
				
		//--------------------------------------
		// METHODS
		//--------------------------------------
		protected function updateData () : void
		{
			// Override this method
			dispatchEvent(new Event(Model.MODEL_CHANGE));
		}
		
	}
	
}
