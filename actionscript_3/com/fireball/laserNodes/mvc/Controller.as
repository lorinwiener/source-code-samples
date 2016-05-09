package com.fireball.laserNodes.mvc
{
		
	//--------------------------------------
	// IMPORTS
	//--------------------------------------
	import flash.events.Event;
	
	//--------------------------------------
	// CLASS
	//--------------------------------------
	/**
	 * Base controller class for MVC Architecture
	*/
	public class Controller
	{
		
		//--------------------------------------
		// PROPERTIES
		//--------------------------------------
		
		
		// PRIVATE
		private var _model:Model;
		
		
		//--------------------------------------
		// CONSTRUCTOR
		//--------------------------------------
		public function Controller (argModel : Model)
		{			
			_model = argModel;
		}
		
		
		//--------------------------------------
		// GETTERS AND SETTERS
		//--------------------------------------
		public function get model () : *
		{
			return _model;
		}
		
		public function set model (argModel : Model)  : void
		{
			_model = argModel;
		}

	}
	
}
