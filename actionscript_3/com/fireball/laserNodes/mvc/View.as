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
	 * Base view class for MVC architecture
	*/
	public class View
	{

		//--------------------------------------
		// PROPERTIES
		//--------------------------------------
		
		// PRIVATE
		private var _model : Model;
		private var _controller : Controller;
		
		//--------------------------------------
		// CONSTRUCTOR
		//--------------------------------------
		/**
	 	 * Constructor to establish the model and controller as well as the model event listener
		*/
		public function View (argModel : Model, argController : Controller)
		{
			_model = argModel;
			_controller = argController;
			
			_model.addEventListener (Model.MODEL_CHANGE, update);
		}
		
		//--------------------------------------
		// GETTERS AND SETTERS
		//--------------------------------------
		public function get model () : *
		{
			return _model;
		}
		
		public function set model (argModel : Model) : void
		{
			_model = argModel;
		}
		
		public function get controller ()  :  *
		{
			return _controller;
		}
		
		public function set controller (argController : Controller) : void
		{
			_controller = argController;
		}
		
		//--------------------------------------
		// METHODS
		//--------------------------------------
		
		// PUBLIC
		public function update (event : Event = null)  :  void
		{
			// Override this method
		}

	}
	
}
