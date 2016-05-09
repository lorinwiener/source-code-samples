﻿package com.xyzcompany.templateClasses{		//--------------------------------------	// IMPORTS	//--------------------------------------	import flash.events.Event;	import flash.events.EventDispatcher;			//--------------------------------------	// CLASS	//--------------------------------------	/**	 * This is the typical format of a simple multiline comment	 * such as for a <code>SampleClass<code> class. *	 *	 * <p><u>REVISIONS</u>:<br>	 * <table width="500" cellpadding="0">	 * <tr><th>Date</th><th>Author</th><th>Description</th></tr>	 * <tr><td>MM/DD/YYYY</td><td>AUTHOR</td><td>Class created.</td></tr>	 * <tr><td>MM/DD/YYYY</td><td>AUTHOR</td><td>DESCRIPTION.</td></tr>	 * </table>	 * </p>	 * @example Here is a code example.	 * <listing version="3.0" >	 *	//Code example goes here.	 * </listing>	 *	 * <span class="hide">Any hidden comments go here.</span> *	*/	public class SampleClass extends EventDispatcher implements ISampleInterface	{		//--------------------------------------		// PROPERTIES		//--------------------------------------						// PUBLIC CONSTANTS		/**		 * Comment for <code>PUBLIC_STATIC_CONSTANT</code>.		 *		 * @default PUBLIC_STATIC_CONSTANT		 */		public static const PUBLIC_STATIC_CONSTANT : String = "publicStaticContant";		public static const PUBLIC_STATIC_CONSTANT_2 : String = "publicStaticContant2";						// PRIVATE VARIABLES		/**		 * Comment for _sample_str.		 */		private var _sample_str : String;				/**		 * Comment for _sample2_str.		 */		private var _sample2_str : String;				//--------------------------------------		// CONSTRUCTOR		//--------------------------------------		/**	 	 * This is the typical format of a simple multiline comment	 	 * such as for a <code>SampleClass</code> constructor.	 	 *	 	 * <span class="hide">Any hidden comments go here.</span>	 	 *	 	 * @param param1 Describe param1 here.	 	 * @param param2 Describe param2 here,		*/		public function SampleClass ()		{			// SUPER			super ();					// LOCAL VARIABLES			var localSample_str : String = SampleClass.PUBLIC_STATIC_CONSTANT;			var isSample_bool : Boolean = true;					// PROPERTIES					_sample_str = SampleClass.PUBLIC_STATIC_CONSTANT;			_sample2_str = SampleClass.PUBLIC_STATIC_CONSTANT_2;					// METHODS			sampleMethod (_sample_str, _sample2_str);					//EVENTS			addEventListener (Event.INIT, onInit);				}						// PUBLIC GETTER/SETTERS		/**		 * This is the typical format of a simple comment for sample.		 *		 */		public function get sample () : String {			return _sample_str;		}				public function set sample (aValue: String) : void {			_sample_str = aValue;		}				/**		 * This is the typical format of a simple comment for sample.		 *		 */		public function get sample2 () : String {			return _sample2_str;		}				public function set sample2 (aValue: String) : void {			_sample2_str = aValue;		}					//--------------------------------------		// METHODS		//--------------------------------------						// PUBLIC		/**		 *		 * This is the typical format of a simple multiline comment		 * such as for a <code>sampleMethod</code> method.		 *		 * <span class="hide">Any hidden comments go here.</span>		 *		 * @param param1 Describe param1 here.		 * @param param2 Describe param2 here.		 * 		 * @return void		 */		public function sampleMethod (aArgument_str : String, aArgument2_str : String) : void		{			sampleMethod2 (aArgument_str, aArgument2_str);		}				// PRIVATE		/**		 * This is the typical format of a simple multiline comment		 * such as for a <code>sampleMethod</code> method.		 * 		 * <span class="hide">Any hidden comments go here.</span>		 * 		 * @param param1 Describe param1 here.		 * @param param2 Describe param2 here.		 *  		 * @return void		 */		private function sampleMethod2 (aArgument_str : String, aArgument2_str : String) : void		{			dispatchSample (aArgument_str, aArgument2_str);		}				//--------------------------------------		// EVENTS		//--------------------------------------				// EVENT DISPATCHERS		/**		 * Dispatches the Event.SAMPLE event.		 */		private function dispatchSample (aArgument_str : String, aArgument2_str : String) : void		{			// dispatchEvent ();		}				// EVENT HANDLERS		/**		 * Handles the Event.INIT event.		 */		private function onInit (event : Event) : void {			/**			 * Comment for _isSample_bool.			 */			var _isSample_bool : Boolean;			// TODO: Insert Code Here		}			}	}