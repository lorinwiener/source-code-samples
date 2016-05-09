package com.liquident.actionpage 
{
	import caurina.transitions.Tweener;
	
	import com.liquident.Enums;
	import com.liquident.GameStateEvent;
	import com.liquident.SocialNetworkConfig;
	import com.liquident.Utility;
	import com.liquident.assetmanager.AssetManager;
	import com.liquident.assetmanager.assetevents.AssetManagerErrorEvent;
	import com.liquident.assetmanager.assetevents.AssetManagerEvent;
	import com.liquident.assetmanager.assettypes.AssetImage;
	import com.liquident.networkinterface.NetCommand;
	import com.liquident.networkinterface.NetworkInterfaceEvent;
	import com.liquident.networkinterface.netcommanddata.PurchaseOfferCommandData;
	import com.liquident.popups.BasicPopup;
	import com.liquident.popups.GeneralPopup;
	import com.liquident.popups.IPopup;
	import com.liquident.popups.PopupEvent;
	import com.liquident.ui.FrameProgressBar;
	import com.liquident.ui.IListItem;
	import com.liquident.ui.List;
	import com.liquident.ui.ProgressBar;
	import com.liquident.ui.SingleSelectButtonGroup;
	import com.liquident.ui.SliderEvent;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import pages.ActionsPage;
	
	/**
	 * ...
	 * @author Scott
	 */
	public class ActionList extends List
	{
		protected var _selectionGroup:SingleSelectButtonGroup
		protected var _selectionID:int;
		
		//public var TXT_TabDescription:TextField;
		public var TXT_Instructions:TextField;

		// Tabs
		public var MC_Tab1_Inactive:MovieClip;
		public var MC_Tab2_Inactive:MovieClip;
		public var MC_Tab3_Inactive:MovieClip;
		public var MC_Tab4_Inactive:MovieClip;
		public var MC_Tab5_Inactive:MovieClip;
		public var MC_Tab6_Inactive:MovieClip;
		private var _tabsInactiveArray:Array;
		
		public var MC_Tab1_Active:MovieClip;
		public var MC_Tab2_Active:MovieClip;
		public var MC_Tab3_Active:MovieClip;
		public var MC_Tab4_Active:MovieClip;
		public var MC_Tab5_Active:MovieClip;
		public var MC_Tab6_Active:MovieClip;
		private var _tabsActiveArray:Array;
		
		public var MC_Tab_Scroll_L:MovieClip;
		public var MC_Tab_Scroll_R:MovieClip;

		// Tiers
		public var MC_Tier1:MovieClip;
		public var MC_Tier2:MovieClip;
		public var MC_Tier3:MovieClip;
		public var MC_Tier4:MovieClip;
		public var MC_TierScrollLeft:MovieClip;
		public var MC_TierScrollRight:MovieClip;
		private var _tiersMCArray:Array;
		
		// Header above scrollable actions
		public var MC_ActionTitle:MovieClip;
		public var TXT_ActionTitle:TextField;
		
		// Boss action
		public var MC_ActionEntry_Boss:MovieClip;
		//public var MC_BossAction_BG:MovieClip;
		protected var _bossActionID:int;
		protected var _bossActionReqMCsArray:Array;
		private var _bossActionProgressBar:ProgressBar;
		private var _currentBossActionObj:Object;
		private var _bossActionLockReason:String;

		// Tab/tier menu tracking
		public var _currentTab:int;					// index of the selected visible tab (0 thru 5)
		public var _currentTier:int;					// index of the selected visible tier (0 thru 3)
		private var _currentTabOffset:int;			// offset index of the tab within the row of available tabs (can be as larger as the action_tab_tiers table)
		private var _currentTierOffset:int;			// offset index of the tier within the row of available tiers (can be as large as tier_10, as set in action_tab_tiers table)
		public var _currentTabDataIndex:int;	// current 'tab' index used to find data within Main.gs.actionsList
		//public var _currentTierDataIndex:int;	// current 'tier' index iused to find data within Main.gs.actionsList
		private var _tabsDataArray:Array;
		private var _tierNamesArray:Array;
		private var _activeTabID:String;

		// Formatting
		private var _formatTabNormal:TextFormat;
		private var _formatTabSelected:TextFormat;
		private var _formatTierNormal:TextFormat;
		private var _formatTierSelected:TextFormat;

		// Reference to the owning ActionsPage
		private var _actionsPage:ActionsPage;
		
		public static const NUM_VISIBLE_TABS:int = 6;
		public static const NUM_VISIBLE_TIERS:int = 4;
		public static const NUM_BOSS_ACTION_ITEM_REQS:int = 6;
		public static const CAREERS_PAGE_TEXT:String = "Careers";
		public static const LEADERBOARD_PAGE_TEXT:String = "Leaderboard";
		public static const BOSS_ACTION_START_X:Number = 23.00;//14.55;
		public static const BOSS_ACTION_START_Y:Number = 42.5;
		public static const BOSS_ACTION_HEIGHT:Number = 216.55;
		public static const BOSS_ACTION_ITEM_REQ_BG_HEIGHT:Number = 170.10;
		public static const BOSS_ACTION_ITEM_REQ_ENTRY_HEIGHT:Number = 20;// Actual height is 22.5, but they overlap, so we adj.
		
		private static const ACTION_DETAILS_IMAGE_URL:String = "/flash/bin/images/ActionImages/";
		
		/**
		 * Construct
		 * */
		public function ActionList() 
		{
			//trace("ActionList construct");
			super();
			setDefaultTextFormatting();
		}
		
		/** 
		 * Accessor function for setting the owning action page reference.
		 * */
		public function set actionsPage( owningPage:ActionsPage ):void {
			_actionsPage = owningPage;
		}

		/** 
		 * Initialization of text formatting types used in the list.
		 * */
		private function setDefaultTextFormatting():void {

			_formatTabNormal = new TextFormat(null, 11, null, false, null, null, null, null, TextFormatAlign.CENTER);
			_formatTabSelected = new TextFormat(null, 12, null, true, null, null, null, null, TextFormatAlign.CENTER);
			_formatTierNormal = new TextFormat(null, 11, null, false, null, null, null, null, TextFormatAlign.CENTER);
			_formatTierSelected = new TextFormat(null, 12, null, true, null, null, null, null, TextFormatAlign.CENTER);
			
		}
		
		/**
		 * Initialize the data and list layout.
		 * */
		override protected function init(e:Event = null):void 
		{
			//trace("ActionList init");
			
			super.init(e);
			
			_selectionGroup = new SingleSelectButtonGroup([]);
			cellClass = ActionEntry;

			_currentTab = getStartingTab();
			_currentTier = 1;// getUserActionTierLevelByTabID( _currentTab ) ;
			_currentTabOffset = 0;
			_currentTierOffset = 0;
			_currentTabDataIndex = 7;
		
			initTabsTiersData();					
			createTabTierListeners();
			setupTabs();

			_bossActionProgressBar = new FrameProgressBar( MC_ActionEntry_Boss.MC_ProgressBar );
			
			initBossActionReqsArray();
			_currentBossActionObj = new Object();
			setupBossAction();
							
			addBossActionListeners();
			
			// Fill the tlist with action data based on the tab/tier defaults
			//selectDefaultTab();
		}
		
		/** 
		 * Cleanup list and listeners.
		 * */
		override public function cleanup():void
		{
			super.cleanup();
			
			removeBossActionListeners();
			
			MC_Tab1_Inactive.removeEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab2_Inactive.removeEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab3_Inactive.removeEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab4_Inactive.removeEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab5_Inactive.removeEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab6_Inactive.removeEventListener( MouseEvent.CLICK, onSelectTab );
			
			MC_Tab_Scroll_L.removeEventListener( MouseEvent.CLICK, onTabScrollLeft );
			MC_Tab_Scroll_R.removeEventListener( MouseEvent.CLICK, onTabScrollRight );
			MC_Tier1.removeEventListener( MouseEvent.CLICK, onSelectTier );
			MC_Tier2.removeEventListener( MouseEvent.CLICK, onSelectTier );
			MC_Tier3.removeEventListener( MouseEvent.CLICK, onSelectTier );
			MC_Tier4.removeEventListener( MouseEvent.CLICK, onSelectTier );
			
			MC_TierScrollLeft.removeEventListener( MouseEvent.CLICK, onScrollTierLeft );
			MC_TierScrollRight.removeEventListener( MouseEvent.CLICK, onScrollTierRight );
			
			Main.assetMgr.removeEventListener( AssetManagerEvent.ASSET_LOAD_COMPLETE, onBackgroundImageLoaded );
			Main.assetMgr.removeEventListener( AssetManagerErrorEvent.ASSET_LOAD_ERROR, onBackgroundImageError );
			
			MC_ActionEntry_Boss.MC_BossDescription.removeEventListener( Event.ENTER_FRAME, stopShowDescription );	
			MC_ActionEntry_Boss.MC_BossDescription.removeEventListener( Event.ENTER_FRAME, stopHideDescription );	
			
			MC_Scroller.removeEventListener(SliderEvent.SCROLL, onScroll);
			
			Main.netMgr.removeEventListener("offersPurchaseSuccess", onPurchaseSuccess);
			Main.netMgr.removeEventListener("offersPurchaseFailure", onPurchaseFail);
			
			if( _selectionGroup ) {
				_selectionGroup.cleanup();
				_selectionGroup = null;	
			}
			
			if( TXT_Instructions && TXT_Instructions.parent ) {
				TXT_Instructions.parent.removeChild( TXT_Instructions );
			}
			TXT_Instructions = null;
			
			// Tabs
			if( MC_Tab1_Inactive && MC_Tab1_Inactive.parent ) {
				MC_Tab1_Inactive.parent.removeChild( MC_Tab1_Inactive );
			}
			MC_Tab1_Inactive = null;
			if( MC_Tab2_Inactive && MC_Tab2_Inactive.parent ) {
				MC_Tab2_Inactive.parent.removeChild( MC_Tab2_Inactive );
			}
			MC_Tab2_Inactive = null;
			if( MC_Tab3_Inactive && MC_Tab3_Inactive.parent ) {
				MC_Tab3_Inactive.parent.removeChild( MC_Tab3_Inactive );
			}
			MC_Tab3_Inactive = null;
			if( MC_Tab4_Inactive && MC_Tab4_Inactive.parent ) {
				MC_Tab4_Inactive.parent.removeChild( MC_Tab4_Inactive );
			}
			MC_Tab4_Inactive = null;
			if( MC_Tab5_Inactive && MC_Tab5_Inactive.parent ) {
				MC_Tab5_Inactive.parent.removeChild( MC_Tab5_Inactive );
			}
			MC_Tab5_Inactive = null;
			if( MC_Tab6_Inactive && MC_Tab6_Inactive.parent ) {
				MC_Tab6_Inactive.parent.removeChild( MC_Tab6_Inactive );
			}
			MC_Tab6_Inactive = null;
			_tabsInactiveArray.length = 0;
			_tabsInactiveArray = null;
			
			if( MC_Tab1_Active && MC_Tab1_Active.parent ) {
				MC_Tab1_Active.parent.removeChild( MC_Tab1_Active );
			}
			MC_Tab1_Active = null;
			if( MC_Tab2_Active && MC_Tab2_Active.parent ) {
				MC_Tab2_Active.parent.removeChild( MC_Tab2_Active );
			}
			MC_Tab2_Active = null;
			if( MC_Tab3_Active && MC_Tab3_Active.parent ) {
				MC_Tab3_Active.parent.removeChild( MC_Tab3_Active );
			}
			MC_Tab3_Active = null;
			if( MC_Tab4_Active && MC_Tab4_Active.parent ) {
				MC_Tab4_Active.parent.removeChild( MC_Tab4_Active );
			}
			MC_Tab4_Active = null;
			if( MC_Tab5_Active && MC_Tab5_Active.parent ) {
				MC_Tab5_Active.parent.removeChild( MC_Tab5_Active );
			}
			MC_Tab5_Active = null;
			if( MC_Tab6_Active && MC_Tab6_Active.parent ) {
				MC_Tab6_Active.parent.removeChild( MC_Tab6_Active );
			}
			MC_Tab6_Active = null;
			_tabsActiveArray.length = 0;
			_tabsActiveArray = null;
			
			if( MC_Tab_Scroll_L && MC_Tab_Scroll_L.parent ) {
				MC_Tab_Scroll_L.parent.removeChild( MC_Tab_Scroll_L );
			}
			MC_Tab_Scroll_L = null;
			if( MC_Tab_Scroll_R && MC_Tab_Scroll_R.parent ) {
				MC_Tab_Scroll_R.parent.removeChild( MC_Tab_Scroll_R );
			}
			MC_Tab_Scroll_R = null;
			
			// Tiers
			if( MC_Tier1 && MC_Tier1.parent ) {
				MC_Tier1.parent.removeChild( MC_Tier1 );
			}
			MC_Tier1 = null;
			if( MC_Tier2 && MC_Tier2.parent ) {
				MC_Tier2.parent.removeChild( MC_Tier2 );
			}
			MC_Tier2 = null;
			if( MC_Tier3 && MC_Tier3.parent ) {
				MC_Tier3.parent.removeChild( MC_Tier3 );
			}
			MC_Tier3 = null;
			if( MC_Tier4 && MC_Tier4.parent ) {
				MC_Tier4.parent.removeChild( MC_Tier4 );
			}
			MC_Tier4 = null;
			if( MC_TierScrollLeft && MC_TierScrollLeft.parent ) {
				MC_TierScrollLeft.parent.removeChild( MC_TierScrollLeft );
			}
			MC_TierScrollLeft = null;
			if( MC_TierScrollRight && MC_TierScrollRight.parent ) {
				MC_TierScrollRight.parent.removeChild( MC_TierScrollRight );
			}
			MC_TierScrollRight = null;
			_tiersMCArray.length = 0;
			_tiersMCArray = null;
			
			// Boss action
			if( MC_ActionEntry_Boss && MC_ActionEntry_Boss.parent ) {
				MC_ActionEntry_Boss.parent.removeChild( MC_ActionEntry_Boss );
			}
			MC_ActionEntry_Boss = null;
			_bossActionReqMCsArray.length = 0;
			_bossActionReqMCsArray = null;
			_bossActionProgressBar = null;
			_currentBossActionObj = null;
			_bossActionLockReason = null;
			
			// Tab/tier menu tracking
			_tabsDataArray.length = 0;
			_tabsDataArray = null;
			_tierNamesArray.length = 0;
			_tierNamesArray = null;
			_activeTabID = null;
			
			// Formatting
			_formatTabNormal = null;
			_formatTabSelected = null;
			_formatTierNormal = null;
			_formatTierSelected = null;
			
			// Reference to the owning ActionsPage
			_actionsPage = null;
			
			while( MC_Holder.numChildren ) {
				MC_Holder.removeChildAt( 0 );
			}
			if( MC_Holder && MC_Holder.parent ) {
				MC_Holder.parent.removeChild( MC_Holder );
			}
			MC_Holder = null;
		}
		

		/**
		 * ActionList only keeps/uses data for actions which are currently active and match the user's career.
		 * It makes a copy of the data array given to it.
		 */
		override public function get data():Array
		{ 
			return super.data; 
		}
		

		/**
		 * Helper funciton to be called from the Nav Menu if/when the user attempts to switch action types while the page is already open.
		 * */
		public function resetForDisplayModeChange():void {

			//trace( "resetForDisplayModeChange" );
			
			_currentTab = getStartingTab();
			_currentTier = 1;
			_currentTabOffset = 0;
			_currentTierOffset = 0;
			_currentTabDataIndex = 7;
		
			_tabsActiveArray.length = 0;
			_tabsInactiveArray.length = 0;
			_tabsDataArray.length = 0;
			_tierNamesArray.length = 0;
			_tiersMCArray.length = 0;

			// Rest the scrollbar to the top position so the boss action element sets correctly.
			scrollTo( 0 );

			initTabsTiersData();					
			setupTabs();

			// Store starting points for scrolling calculations
			_bossActionProgressBar = null;
			_bossActionProgressBar = new FrameProgressBar( MC_ActionEntry_Boss.MC_ProgressBar );
			
			_bossActionReqMCsArray.length = 0;
			initBossActionReqsArray();
			
			_currentBossActionObj = null;
			_currentBossActionObj = new Object();
			
			//trace( "resetForDisplayModeChange refresh list data" );
			_actionsPage.groupActions( Main.gs.actionsList );
			setupBossAction();
		}
		
		/**
		 * ActionList only keeps/uses data for actions which are currently active and match the user's career.
		 * It makes a copy of the data array given to it.
		 */
		override public function set data(value:Array):void 
		{
			var activeData:Array = [];
			//trace("ActionList setData with " + value.length);

			for( var actionIndex:int = 0; actionIndex < value.length; ++actionIndex ){
				// Fill the data array with actions for that active 'action tab & tier'
				//trace( "ActionList setData is_boss_action " + value[actionIndex].is_boss_action );
				if( value[actionIndex].is_boss_action != 1 ){
					activeData.push( value[actionIndex] );
				}
				else {
					// Store the boss action ID for processing the action attempt later.
					_bossActionID = value[actionIndex].action_id;
				}
			}
			
			// Do not sort anymore leave them as they are ordered in the DB
			//activeData.sortOn( ["lvl_required", "career_level_required"], Array.NUMERIC );
			super.data = activeData;
			
			// Refresh the bossaction data
			testBossActionAvailable();
		}
		
		
		/** 
		 * Adds listeners for all tab tier functionality.
		 * */
		private function createTabTierListeners():void {
			// Create event listeners per tab.  Only inactives need to listen for interaction.
			MC_Tab1_Inactive.addEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab2_Inactive.addEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab3_Inactive.addEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab4_Inactive.addEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab5_Inactive.addEventListener( MouseEvent.CLICK, onSelectTab );
			MC_Tab6_Inactive.addEventListener( MouseEvent.CLICK, onSelectTab );

			MC_Tab_Scroll_L.addEventListener( MouseEvent.CLICK, onTabScrollLeft );
			MC_Tab_Scroll_R.addEventListener( MouseEvent.CLICK, onTabScrollRight );
		}
		
		/** 
		 * Initialize the local tracking arrays and sort them if necessary.
		 * */
		private function initTabsTiersData():void {

			//trace("initTabsTiersData");
			
			_tabsActiveArray = new Array();
			_tabsActiveArray.push( MC_Tab1_Active );
			_tabsActiveArray.push( MC_Tab2_Active );
			_tabsActiveArray.push( MC_Tab3_Active );
			_tabsActiveArray.push( MC_Tab4_Active );
			_tabsActiveArray.push( MC_Tab5_Active );
			_tabsActiveArray.push( MC_Tab6_Active );
			
			_tabsInactiveArray = new Array();
			_tabsInactiveArray.push( MC_Tab1_Inactive );
			_tabsInactiveArray.push( MC_Tab2_Inactive );
			_tabsInactiveArray.push( MC_Tab3_Inactive );
			_tabsInactiveArray.push( MC_Tab4_Inactive );
			_tabsInactiveArray.push( MC_Tab5_Inactive );
			_tabsInactiveArray.push( MC_Tab6_Inactive );


			_tabsDataArray = new Array();
			 
			// Loop through the remaining tabs and add any non-careers
			var tempTabs:Array = new Array();
			tempTabs = Main.gs.getActionTabTiers();
			var tabData:Object = null;
			for each( tabData in tempTabs ) {
				
				// filter career and non-career types
				if( Main.gs.actionListDisplayMode == Enums.ACTIONS_DISPLAY_MODE_CAREERS ) {
					if ( tabData.career_id > 0 ) {
						// Add all careers
						//trace("_listDisplayMode adding career " + tabData );
						_tabsDataArray.push( tabData );
					}
				}
				else {
					// Add all non-career tabs
					if ( tabData.career_id == 0 ) {
						//trace("_listDisplayMode adding social " + tabData );
						_tabsDataArray.push( tabData );
					}
				}
			}
			
			//trace( "initTabsTiersData currentTab is " + _currentTab ); 
			_currentTabDataIndex = _tabsDataArray[_currentTab-1].att_id;
			//trace( "initTabsTiersData currentTabDataIndex is " +  _currentTabDataIndex ); 
			
			_tierNamesArray = new Array();
			
			// Inite the array for indexing through MCs later.
			_tiersMCArray = new Array();
			_tiersMCArray[0] = MC_Tier1;
			_tiersMCArray[1] = MC_Tier2;
			_tiersMCArray[2] = MC_Tier3;
			_tiersMCArray[3] = MC_Tier4;
		}
		
		/**
		 * The index of the currently selected entry, or -1 for no selection. This function searches the list.
		 */
		public function get selectionID():int
		{
			for (var i:int = 0; i < _data.length; ++i) {
				if (_cells[i] == _selectionGroup.selection) {
					_selectionID = i;
					return i;
				}
			}
			
			_selectionID = -1;
			return _selectionID;
		}
		
		
		/** 
		 * 
		 * */
		public function set selectionID( id:int ):void
		{
			if (id >= 0 && id < _data.length) {
				_selectionGroup.selection = _cells[id];
				
				if (MC_Scroller.isEnabled) {
					MC_Scroller.percentage = Number(id) / (_data.length - 1);
				}
			}
			else {
				_selectionGroup.selection = null;
				if (MC_Scroller.isEnabled) {
					MC_Scroller.percentage = 0;
				}
			}
		}
		
		/**
		 * Add tab specific text, event listeners, and related tier data.
		 * */
		private function setupTabs():void {

			//trace("__setupTabs");
			
			//setActiveTab( "MC_Tab1_Inactive" ) ;
			setActiveTab( _tabsInactiveArray[_currentTab-1].name );
			setTabText();
			
			//trace( "setupTabs _tabsDataArray.length " + _tabsDataArray.length );
			
			// Hide the scroll arows if their are not enough tabs to scroll
			if ( _tabsDataArray.length < NUM_VISIBLE_TABS+1 ) {
				MC_Tab_Scroll_L.visible = false;
				MC_Tab_Scroll_R.visible = false;
			}
			else {
				MC_Tab_Scroll_L.visible = true;
				MC_Tab_Scroll_R.visible = true;
			}
		
			setupTiers();
		}

		/**
		 * Handle the button input for moving the tabs to the left.
		 * */
		private function onTabScrollLeft( e:MouseEvent ) {
			//trace("onTabScrollLeft");
			var TabMax:int = Main.gs.getActionTabTiers().length;
			if( _currentTabOffset >= TabMax-NUM_VISIBLE_TABS ){
				_currentTabOffset--;
				setTabText( _currentTabOffset ) ;
				shiftActiveTab( false );
			}
		}
		
		/** 
		 * Handle the button input for moving the tabs to the right.
		 * */
		private function onTabScrollRight( e:MouseEvent ) {
			//trace("onTabScrollRight");
			var TabMax:int = Main.gs.getActionTabTiers().length;
			if( _currentTabOffset < TabMax-NUM_VISIBLE_TABS ){
				_currentTabOffset++;
				setTabText( _currentTabOffset ) ;
				shiftActiveTab( true );
			}
		}
		
		/**
		 * Move the 'active' selected tab as the tab data scrolls left or right
		 * */
		private function shiftActiveTab( shiftRight:Boolean ):void {
			if ( shiftRight ) {
				if ( _activeTabID == "MC_Tab1_Inactive" ) {
					_activeTabID = "none";
				}
				else if ( _activeTabID == "MC_Tab2_Inactive" ) {
					_activeTabID = "MC_Tab1_Inactive";
				}
				else if ( _activeTabID == "MC_Tab3_Inactive" ) {
					_activeTabID = "MC_Tab2_Inactive";
				}
				else if ( _activeTabID == "MC_Tab4_Inactive" ) {
					_activeTabID = "MC_Tab3_Inactive";
				}
				else if ( _activeTabID == "MC_Tab5_Inactive" ) {
					_activeTabID = "MC_Tab4_Inactive";
				}
				else if ( _activeTabID == "MC_Tab6_Inactive" ) {
					_activeTabID = "MC_Tab5_Inactive";
				}
				else if (  _activeTabID == "none" ) {
					_activeTabID = "MC_Tab6_Inactive";
				}
			}
			else {
				if ( _activeTabID == "MC_Tab1_Inactive" ) {
					_activeTabID = "MC_Tab2_Inactive";
				}
				else if ( _activeTabID == "MC_Tab2_Inactive" ) {
					_activeTabID = "MC_Tab3_Inactive";
				}
				else if ( _activeTabID == "MC_Tab3_Inactive" ) {
					_activeTabID = "MC_Tab4_Inactive";
				}
				else if ( _activeTabID == "MC_Tab4_Inactive" ) {
					_activeTabID = "MC_Tab5_Inactive";
				}
				else if ( _activeTabID == "MC_Tab5_Inactive" ) {
					_activeTabID = "MC_Tab6_Inactive";
				}
				else if ( _activeTabID == "MC_Tab6_Inactive" ) {
					_activeTabID = "none";
				}
				else if (  _activeTabID == "none" ) {
					_activeTabID = "MC_Tab1_Inactive";
				}
			}
			
			setActiveTab( _activeTabID ) ;
		}
		
		
		/** 
		 * Set the data and visible appearance of a selected tab.
		 * */
		private function setActiveTab( tabID:String ) {

			//trace("__ setActiveTab " + tabID);
			
			var tabsIndex:int = 0;
			// shut all tabs off
			while ( tabsIndex <  NUM_VISIBLE_TABS ) {
				_tabsActiveArray[ tabsIndex ].visible = false;
				_tabsInactiveArray[ tabsIndex ].visible = false;
				++tabsIndex;
			}
			// default everything to inactive
			tabsIndex = 0;
			while ( tabsIndex <  NUM_VISIBLE_TABS ) {
				_tabsInactiveArray[ tabsIndex ].visible = true;
				++tabsIndex;
			}
			
			// set the tabs to the data
			tabsIndex = 0;
			while( ( tabsIndex < _tabsDataArray.length ) && ( tabsIndex < NUM_VISIBLE_TABS ) ) {
				
				// Find the tab by name, (tabID == "MC_Tab1_Inactive")
				if ( tabID == _tabsInactiveArray[ tabsIndex ].name ) {
					// Show the Active tab over the inactive.
					_tabsActiveArray[ tabsIndex ].visible = true;
					// Set the current tab
					_currentTab = _currentTabOffset + tabsIndex + 1;
					// Set the data index so we look up the correct data to fill the list
					_currentTabDataIndex = _tabsDataArray[_currentTab-1].att_id;
				}
				
				++tabsIndex;
			}
			
			if ( _tabsDataArray.length < 7 ) {
				MC_Tab_Scroll_L.visible = false;
				MC_Tab_Scroll_R.visible = false;
			}
			else {
				MC_Tab_Scroll_L.visible = true;
				MC_Tab_Scroll_R.visible = true;
			}
			
			// Track the name of the 'selected' tab
			_activeTabID = tabID;
			// Update the tier names for the selected tab.
			setupTierText();
		}
		
		
		/** 
		 * Set the tab name text into the tab MCs
		 * */
		private function setTabText( tabOffset:int = 0 ) :void{
			
			//trace("setTabText tabOffset " + tabOffset );
			//trace("setTabText tabsArray " + _tabsDataArray.length );

			var tabSetIndex:int = 0;
			while( tabSetIndex < NUM_VISIBLE_TABS ) {
				_tabsActiveArray[tabSetIndex].visible = false;
				_tabsInactiveArray[tabSetIndex].visible = true;
				_tabsInactiveArray[tabSetIndex].category.text = "";
				
				++tabSetIndex;
			}
			
			var tabDataIndex:int = 0;
			while( ( tabDataIndex < _tabsDataArray.length ) && ( tabDataIndex < NUM_VISIBLE_TABS ) ) {

				_tabsInactiveArray[tabDataIndex].category.text = _tabsDataArray[tabDataIndex + tabOffset].tab_name;
				_tabsInactiveArray[tabDataIndex].category.setTextFormat( _formatTabNormal );
				_tabsInactiveArray[tabDataIndex].visible = true;
				
				_tabsActiveArray[tabDataIndex].category.text = _tabsDataArray[tabDataIndex + tabOffset].tab_name;
				_tabsActiveArray[tabDataIndex].category.setTextFormat( _formatTabSelected );
				if( tabDataIndex == _currentTab-1 ){
					_tabsActiveArray[tabDataIndex].visible = true;
				}

				++tabDataIndex;
			}
		}
		
		/**
		* Handle the input of selecting a given action tab.
		 * */
		private function onSelectTab( e:Event ) {
			//trace( "onSelectTab " + e.currentTarget.name );
			scrollTo( 0 );
			setActiveTab( e.currentTarget.name );
			var userTierLevels:Object =  Main.gs.userActionTierLevels;
			_currentTier = userTierLevels.contents[_currentTabDataIndex - 1].action_tier_level;
			if ( _currentTier == 0 ) {
				// Override the default tier if the user's action_tier_level has not been initialized yet.  We now want to display
				// actions for all careers, regardless of the user's career choice.  Or lack of a career if the user is a slacker living in 
				// his/her parents basement.
				_currentTier = 1;
			}
			_actionsPage.groupActions( Main.gs.actionsList );
			setupBossAction();
			shiftActiveTier();
		}

		/** 
		 * Fills the data for the first upon opening or refreshing page list.
		 * */
		public function setupForDisplayMode( displayMode:int ) {
			
			//trace("__setupForDisplayMode displayMode " + displayMode );
			
			// Test if we need to update the display mode and refresh all data
			if ( displayMode == Enums.ACTIONS_DISPLAY_MODE_CAREERS ) {
				if ( Main.gs.actionListDisplayMode != Enums.ACTIONS_DISPLAY_MODE_CAREERS ) {
					
				}
			}
			else if ( displayMode == Enums.ACTIONS_DISPLAY_MODE_SOCIAL ) {
				if ( Main.gs.actionListDisplayMode != Enums.ACTIONS_DISPLAY_MODE_SOCIAL ) {
					
				}
			}
			else {
				// nothing to reset for display mode.  -1 was passed to just process the list setup.
			}
			
			_actionsPage.groupActions( Main.gs.actionsList );
			setupBossAction();
		}

		/**
		 * Initialize action tiers within tabs.
		 * */
		public function setupTiers():void {
			
			// Set up tiers as 'locked', 'selected', or 'unselected' for the default starting point
			updateTierStates();
	
			// Set the visible name text into tiers
			setupTierText();
				
			// create event listeners per tier 
			MC_Tier1.addEventListener( MouseEvent.CLICK, onSelectTier );
			MC_Tier2.addEventListener( MouseEvent.CLICK, onSelectTier );
			MC_Tier3.addEventListener( MouseEvent.CLICK, onSelectTier );
			MC_Tier4.addEventListener( MouseEvent.CLICK, onSelectTier );
			
			MC_TierScrollLeft.addEventListener( MouseEvent.CLICK, onScrollTierLeft );
			MC_TierScrollRight.addEventListener( MouseEvent.CLICK, onScrollTierRight );
		}

		/**
		 * Create a local tier names array that varies based on the tab selected.
		 * */
		private function fillTierNamesArray():void {
			
			//trace( "fillTierNamesArray " +  _currentTab );
			if ( _currentTab > _tabsDataArray.length ) {
				trace( "fillTierNamesArray  FAILED _currentTab " +  _currentTab  + " is outside the tabsArray.length of " +  _tabsDataArray.length );
				return;
			}
			
			// Empty the array to start.
			_tierNamesArray.length = 0;
			// Adhust the index for accessing the tabsArray
			var tabsArrayIndex:int = _currentTab - 1;
			
			if ( _tabsDataArray[tabsArrayIndex].tier_1 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_1 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_1 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_2 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_2 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_2 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_3 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_3 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_3 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_4 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_4 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_4 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_5 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_5 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_5 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_6 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_6 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_6 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_7 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_7 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_7 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_8 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_8 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_8 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_9 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_9 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_9 );
			}
			if ( _tabsDataArray[tabsArrayIndex].tier_10 != "0" ) {
				//trace("adding " + _tabsDataArray[tabsArrayIndex].tier_10 );
				_tierNamesArray.push( _tabsDataArray[tabsArrayIndex].tier_10 );
			}
			
		}

		
		
		/** 
		 * Helper function for refreshing tiers after leveling up from boss action.
		 * */
		public function updateTiersForLevelUp():void {
			shiftActiveTier();
			moveToNextTierForLevelup();
		}
		
		/** 
		 * Helper function to automatically move the focus to the new tier.  Similar to onSelectTier, but without the event trigger.
		 * */
		private function moveToNextTierForLevelup():void {
						
			//trace("moveToNextTierForLevelup");
			
			var nextMC:MovieClip = getHighestAvailableTierMC();
			if ( nextMC == null ) {
				return;
			}
			
			if ( ( nextMC.name == "MC_Tier4" ) && ( MC_Tier4.currentFrameLabel == "selected" ) ) {
				//trace("tier 4 is already selected");
				//shiftActiveTier();
				scrollTierRight();
			}
			
			// Reset the scrollbar to the top position so the boss action element sets correctly.
			scrollTo( 0 );
			
			// Unselect all tiers
			if ( MC_Tier1.currentFrameLabel != "locked" ) {
				MC_Tier1.gotoAndStop( "notSelected" );
			}
			if ( MC_Tier2.currentFrameLabel != "locked" ) {
				MC_Tier2.gotoAndStop( "notSelected" );
			}
			if ( MC_Tier3.currentFrameLabel != "locked" ) {
				MC_Tier3.gotoAndStop( "notSelected" );
			}
			if ( MC_Tier4.currentFrameLabel != "locked" ) {
				MC_Tier4.gotoAndStop( "notSelected" );
			}
			
			// Set the tier as visibly active
			nextMC.gotoAndStop( "selected" );
			
			// Set the tier for tracking 
			_currentTier = getTierLevelByMCName( nextMC.name );
						
			// Repopulate the action list
			_actionsPage.groupActions( Main.gs.actionsList );

			// Reset the text if necessary
			setupTierText();
			setupBossAction();
		}
		
		/** 
		 * Helper to find the next available Tier MC
		 * */
		public function getHighestAvailableTierMC():MovieClip {

			if ( MC_Tier4.currentFrameLabel == "selected" ) {
				//trace("getHighestAvailableTierMC MC_Tier4" );
				return MC_Tier4;
			}
			else if ( MC_Tier4.currentFrameLabel == "notSelected" ) {
				//trace("getHighestAvailableTierMC MC_Tier4" );
				return MC_Tier4;
			}
			else if ( MC_Tier3.currentFrameLabel == "notSelected" ) {
				//trace("getHighestAvailableTierMC MC_Tier3" );
				return MC_Tier3;
			}
			else if ( MC_Tier2.currentFrameLabel == "notSelected" ) {
				//trace("getHighestAvailableTierMC MC_Tier2" );				
				return MC_Tier2;
			}
			else {// if ( MC_Tier1.currentFrameLabel == "notSelected" ) {
				//trace("getHighestAvailableTierMC MC_Tier1" );			
				return MC_Tier1;
			}
		}
		
		
		/**
		 * Helper function to set the text of into the tabs for available actions.
		 * */
		private function setupTierText():void {
			
			//trace( "setupTierText " +  _currentTab  );
			if ( _currentTab  > _tabsDataArray.length ) {
				trace( "setupTierText  FAILED  _currentTab  " +  _currentTab   + " is outside the tabsArray.length of " +  _tabsDataArray.length );
				return;
			}
			
			// Init the array of tier names from gamestate
			fillTierNamesArray();
			
			var tempTierIndex:int = 0;
			while ( tempTierIndex < NUM_VISIBLE_TIERS ) {

				//trace("setting tier " + tempTierIndex + " text as " + _tierNamesArray[_currentTierOffset + tempTierIndex] );
				if( _currentTierOffset+tempTierIndex < _tierNamesArray.length ){
					_tiersMCArray[ tempTierIndex ].subCategory.text = _tierNamesArray[_currentTierOffset + tempTierIndex];
				}
				else {
					_tiersMCArray[ tempTierIndex ].subCategory.text = "";
				}
				
				++tempTierIndex;
			}
			
			setActionHeaderTitleText();
			
		}
		
		/**
		 * Sets the title of the actions header bar to the same text as that of the selected tier.
		 * */
		private function setActionHeaderTitleText():void {
			
			MC_ActionTitle.TXT_ActionTitle.text = _tierNamesArray[ _currentTier - 1 ] + " Actions";
			
		}
		
		/**
		 * Handle the input of selecting a given tier within an action tab.
		 * */
		private function onSelectTier( e:Event ):void {
		
			//trace( "_____onSelectTier " + e.currentTarget.name );

			// Verify that the tier is available to the player
			var selectedMC:MovieClip = getTierMCByName( e.currentTarget.name );
			if ( selectedMC.currentFrameLabel == "locked" ) {
				//trace("Tier level is LOCKED");
				// Tier is locked, ignore the click
				return;
			}

			if ( selectedMC.currentFrameLabel == "selected" ) {
				//trace("Tier level is already selected skipping onSelectTier");
				// Tier is locked, ignore the click
				return;
			}
			
			// Rest the scrollbar to the top position so the boss action element sets correctly.
			scrollTo( 0 );
			
			// Unselect all tiers
			if ( MC_Tier1.currentFrameLabel != "locked" ) {
				//trace("Tier 1 setting to notSelected " + MC_Tier1.currentFrameLabel);
				MC_Tier1.gotoAndStop( "notSelected" );
			}
			if ( MC_Tier2.currentFrameLabel != "locked" ) {
				//trace("Tier 2 setting to notSelected " + MC_Tier2.currentFrameLabel);
				MC_Tier2.gotoAndStop( "notSelected" );
			}
			if ( MC_Tier3.currentFrameLabel != "locked" ) {
				//trace("Tier 3 setting to notSelected " + MC_Tier3.currentFrameLabel);
				MC_Tier3.gotoAndStop( "notSelected" );
			}
			if ( MC_Tier4.currentFrameLabel != "locked" ) {
				//trace("Tier 4 setting to notSelected " + MC_Tier4.currentFrameLabel );
				MC_Tier4.gotoAndStop( "notSelected" );
			}
			
			// Set the tier as visibly active
			selectedMC.gotoAndStop( "selected" );
			
			// Set the tier for tracking 
			_currentTier = getTierLevelByMCName( e.currentTarget.name );
						
			// Repopulate the action list
			_actionsPage.groupActions( Main.gs.actionsList );

			// Reset the text if necessary
			setupTierText();
			setupBossAction();
			
		}


		/** 
		 * Helper function to find a movie clip asset based on name.
		 * */
		private function getTierMCByName( mcName:String ):MovieClip {
			
			var resultMC:MovieClip = null;
			
			if( mcName == "MC_Tier1" ){
				resultMC = MC_Tier1;
			}
			else if( mcName == "MC_Tier2" ){
				resultMC = MC_Tier2;
			}
			else if( mcName == "MC_Tier3" ){
				resultMC = MC_Tier3;
			}
			else if( mcName == "MC_Tier4" ){
				resultMC = MC_Tier4;
			}

			return resultMC;
		}

		/** 
		 * Helper function to find an index from an movie clip asset based on name.
		 * */
		private function getTierLevelByMCName( mcName:String ):int {
			
			//trace("getTierLevelByMCName " + mcName );
			
			if( mcName == "MC_Tier1" ){
				return _currentTierOffset + 1;
			}
			else if( mcName == "MC_Tier2" ){
				return _currentTierOffset + 2;
			}
			else if( mcName == "MC_Tier3" ){
				return _currentTierOffset + 3;
			}
			else if( mcName == "MC_Tier4" ){
				return _currentTierOffset + 4;
			}

			return 1;
		}

		/** 
		 * Update tier buttons displayed avaiablity.
		 * */
		private function updateTierStates():void {
			
			//trace("updateTierStates");
			
			MC_Tier1.gotoAndStop("locked");
			MC_Tier2.gotoAndStop("locked");
			MC_Tier3.gotoAndStop("locked");
			MC_Tier4.gotoAndStop("locked");

			var userTierLevels:Object =  Main.gs.userActionTierLevels;
			if ( userTierLevels.contents[_currentTabDataIndex-1].action_tier_level > 6 ) {
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("notSelected");
				MC_Tier4.gotoAndStop("selected");
				
				// Now shift the tier three times and select it
				scrollTierRight();
				scrollTierRight();
				scrollTierRight();
				
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("notSelected");
				MC_Tier4.gotoAndStop("selected");
			}
			else if ( userTierLevels.contents[_currentTabDataIndex-1].action_tier_level > 5 ) {
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("notSelected");
				MC_Tier4.gotoAndStop("selected");
				
				// Now shift the tier twice and select it
				scrollTierRight();
				scrollTierRight();

				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("notSelected");
				MC_Tier4.gotoAndStop("selected");
			}
			else if ( userTierLevels.contents[_currentTabDataIndex-1].action_tier_level > 4 ) {
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("notSelected");
				MC_Tier4.gotoAndStop("selected");
				
				// Now shift the tier once and select it
				scrollTierRight();
				//shiftActiveTier();
				
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("notSelected");
				MC_Tier4.gotoAndStop("selected");
			}
			else if ( userTierLevels.contents[_currentTabDataIndex-1].action_tier_level > 3 ) {
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("notSelected");
				MC_Tier4.gotoAndStop("selected");
			}
			else if ( userTierLevels.contents[_currentTabDataIndex-1].action_tier_level > 2 ) {
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("notSelected");
				MC_Tier3.gotoAndStop("selected");
			}
			else if ( userTierLevels.contents[_currentTabDataIndex - 1].action_tier_level > 1 ) {
				MC_Tier1.gotoAndStop("notSelected");
				MC_Tier2.gotoAndStop("selected");
			}
			else {
				// Default to first tier as selected.
				MC_Tier1.gotoAndStop("selected");
			}
			
			_currentTier = userTierLevels.contents[_currentTabDataIndex - 1].action_tier_level;
			if ( _currentTier == 0 ) {
				// Override the default tier if the user's action_tier_level has not been initialized yet.  We now want to display
				// actions for all careers, regardless of the user's career choice.  Or lack of a career if the user is a slacker living in 
				// his/her parents basement.
				_currentTier = 1;
			}
		}

		/**
		 * Helper function to find the tier count of an action tab.
		 * */
		private function getMaxTiersByTab( tabIndex:int ): int{
			var tierCount:int = 0;

			//trace("getMaxTiersByTab tabIndex " + tabIndex );
			//trace("getMaxTiersByTab tabsArray " + _tabsDataArray.length );

			tierCount = ( _tabsDataArray[tabIndex].tier_1 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_2 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_3 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_4 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_5 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_6 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_7 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_8 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_9 != "0" )  ?  tierCount + 1 : tierCount;
			tierCount = ( _tabsDataArray[tabIndex].tier_10 != "0" )  ?  tierCount + 1 : tierCount;
			
			//trace("getMaxTiersByTab tabsArray " + tierCount );
			
			return tierCount;
		}

		/**
		 * Handle button input for moving the tiers displayed to the left (within the tab/tiers list).
		 * */
		private function onScrollTierLeft( e:Event ):void {
			
			var TierMax:int = getMaxTiersByTab( _currentTab-1 );
			//trace( "onScrollTierLeft " + e.currentTarget.name + " TierMax is " + TierMax  + " currentTierOffset is " + _currentTierOffset );
			if( _currentTierOffset > 0 ){
				_currentTierOffset--;
				shiftActiveTier();
			}
		}
		
		/**
		 * Handle button input for moving the tiers displayed to the right (within the tab/tiers list).
		 * */
		private function onScrollTierRight( e:Event ):void {
			//trace( "onScrollTierRight " + e.currentTarget.name  );
			scrollTierRight();
		}		

		private function scrollTierRight():void {
			var TierMax:int = getMaxTiersByTab( _currentTab-1 );
			//trace( "scrollTierRight TierMax is " + TierMax + " currentTierOffset is " + _currentTierOffset );
			if( _currentTierOffset < TierMax-NUM_VISIBLE_TIERS ){
				_currentTierOffset++;
				shiftActiveTier();
			}
		}
		
		/** 
		 * Helper function to find a tier level int based on the displayed name.
		 * */
		private function getTierIDByName( tierName:String ) {

			var tierID:int = 0;
			var testIndex:int = 0;
			
			while ( testIndex < _tierNamesArray.length ) {
				if ( tierName == _tierNamesArray[testIndex] ) {
					tierID = testIndex;
					break;
				}
				
				++testIndex;
			}
			
			return tierID;
		}
		
		/**
		 * Handle the horizontal scrolling of the tiers when the user clicks the << or  >> buttons.
		 * */
		private function shiftActiveTier():void {

			//trace("SHIFT ACTIVE TIER");

			var currentUserTierLevel:int =  getUserActionTierLevelByTabID( _currentTabDataIndex );
			//trace("_currentTabDataIndex  " + _currentTabDataIndex );
			//trace("currentUserTierLevel  " + currentUserTierLevel );
			
			var tierMCArray:Array = new Array();
			tierMCArray[0] = MC_Tier1;
			tierMCArray[1] = MC_Tier2;
			tierMCArray[2] = MC_Tier3;
			tierMCArray[3] = MC_Tier4;
			
			tierMCArray[0].gotoAndStop( "locked" );
			tierMCArray[1].gotoAndStop( "locked" );
			tierMCArray[2].gotoAndStop( "locked" );
			tierMCArray[3].gotoAndStop( "locked" );
			
			setupTierText();
			
			var tierDataMax:int = getMaxTiersByTab( _currentTab-1 );
			var tierMCIdnex:int = 0;
			while ( ( tierMCIdnex < NUM_VISIBLE_TIERS ) && ( tierMCIdnex <  tierDataMax ) ){

				// Find if the tiers states based on thier name text.
				var tempName:String = tierMCArray[tierMCIdnex].subCategory.text;
				if( tempName != "" ){
					var tierLevel:int = getTierIDByName( tempName ) + 1;

					//trace("tier name  " + tempName + " is level " + tierLevel );
					//trace("_currentTier  " + _currentTier + " _currentTierOffset " + _currentTierOffset );
					
					if ( tierLevel > currentUserTierLevel ) {
						//trace("setting tab named " + tempName + " as locked" );
						tierMCArray[tierMCIdnex].gotoAndStop( "locked" );
					}
					else if ( tierLevel == _currentTier ) {//else if( tierLevel == ( _currentTier + _currentTierOffset ) ){
						//trace("setting tab named " + tempName + " as selected" );
						tierMCArray[tierMCIdnex].gotoAndStop( "selected" );
					}
					else {
						//trace("setting tab named " + tempName + " as notSelected" );
						tierMCArray[tierMCIdnex].gotoAndStop( "notSelected" );
					}
					
					// Reset the name after the changed state
					 tierMCArray[tierMCIdnex].subCategory.text = tempName;
				}
				
				++tierMCIdnex;
			}
			
			setupTierText();
		}

		/** 
		 * Setup an array of boss action requirement MCs to cycle through with data as boss actions are loaded.
		 * */
		private function initBossActionReqsArray():void {
			
			_bossActionReqMCsArray = new Array();
			_bossActionReqMCsArray[0] = MC_ActionEntry_Boss.MC_InvestmentHolder_1;
			_bossActionReqMCsArray[1] = MC_ActionEntry_Boss.MC_InvestmentHolder_2;
			_bossActionReqMCsArray[2] = MC_ActionEntry_Boss.MC_InvestmentHolder_3;
			_bossActionReqMCsArray[3] = MC_ActionEntry_Boss.MC_InvestmentHolder_4;
			_bossActionReqMCsArray[4] = MC_ActionEntry_Boss.MC_InvestmentHolder_5;
			_bossActionReqMCsArray[5] = MC_ActionEntry_Boss.MC_InvestmentHolder_6;
			
			/*
			var investmentIndex:int = 0;
			while ( investmentIndex < _bossActionReqMCsArray.length ) {
				_bossActionReqMCsArray[investmentIndex].buttonMode = true;
				_bossActionReqMCsArray[investmentIndex].mouseEnabled = true;
				_bossActionReqMCsArray[investmentIndex].useHandCursor = true;

				//_bossActionReqMCsArray[investmentIndex].statBG.buttonMode = true;
				//_bossActionReqMCsArray[investmentIndex].statBG.mouseEnabled = true;
				//_bossActionReqMCsArray[investmentIndex].statBG.useHandCursor = true;

				//_bossActionReqMCsArray[investmentIndex].TXT_Label.buttonMode = true;
				//_bossActionReqMCsArray[investmentIndex].TXT_Label.mouseEnabled = true;
				//_bossActionReqMCsArray[investmentIndex].TXT_Label.useHandCursor = true;

				//_bossActionReqMCsArray[investmentIndex].TXT_Amt.buttonMode = true;
				//_bossActionReqMCsArray[investmentIndex].TXT_Amt.mouseEnabled = true;
				//_bossActionReqMCsArray[investmentIndex].TXT_Amt.useHandCursor = true;

				++investmentIndex;
			}
			*/
		}
		
		/**
		 * Handle boss entry action list setup.
		 * */
		private function setupBossAction():void {
			
			_currentBossActionObj =  ActionUtility.getBossActionByTabTier( _currentTabDataIndex, _currentTier );
			
			// Store starting points for scrolling calculations
			MC_ActionEntry_Boss.y = BOSS_ACTION_START_Y;
			MC_ActionEntry_Boss.x = BOSS_ACTION_START_X;

			//trace( "setupBossAction X = " + MC_ActionEntry_Boss.x ); 
			//trace( "setupBossAction Y = " + MC_ActionEntry_Boss.y ); 
			
			// Verify that this boss action is performable.
			testBossActionAvailable();
				
			// Set the scrolling description to be off
			MC_ActionEntry_Boss.MC_BossDescription.gotoAndStop("inactive");

			// Update all text for the boss action.
			updateBossActionText();
			
			// Load the background image.
			setBossActionBG();
		}
		
		/** 
		 * */
		private function setBossActionBG():void {

			//trace("**** setBossActionBG " + _currentBossActionObj.details_image + ".png");
			
			if ( _currentBossActionObj != null ) {
				Main.assetMgr.addEventListener( AssetManagerEvent.ASSET_LOAD_COMPLETE, onBackgroundImageLoaded );
				Main.assetMgr.addEventListener( AssetManagerErrorEvent.ASSET_LOAD_ERROR, onBackgroundImageError );
				
				var picUrl:String = SocialNetworkConfig.serverHost + ACTION_DETAILS_IMAGE_URL + _currentBossActionObj.details_image + ".png";
				Main.assetMgr.loadAsset( picUrl, AssetManager.ASSET_TYPE_IMAGE, true );
			}
			
		}

		/** 
		 * */
		private function onBackgroundImageLoaded( e:AssetManagerEvent ):void 
		{
			//trace("**** onBackgroundImageLoaded " + MC_ActionEntry_Boss + " " + MC_ActionEntry_Boss.MC_BossAction_BG );
			
			if( ( MC_ActionEntry_Boss == null ) || ( MC_ActionEntry_Boss.MC_BossAction_BG == null ) ){
				return;
			}
			
			var bossActionBGName:String = "BMP_BossBackground";
			var assetImageBGName:String = _currentBossActionObj.details_image + ".png";
			//trace( "e.assetInfo.url.indexOf( " + _currentBossActionObj.details_image +  " ) = " + e.assetInfo.url.indexOf( assetImageBGName ) );
			// Check to see if this image is relevant to us.
			if ( _currentBossActionObj && e.assetInfo.url.indexOf( assetImageBGName ) > 0 ) {
				
				// remove the old BG image if we previously added one.
				var testChildIndex:int = 0;
				while(  testChildIndex < MC_ActionEntry_Boss.MC_BossAction_BG.numChildren )
				{
					if ( ( MC_ActionEntry_Boss.MC_BossAction_BG.getChildAt( testChildIndex ).name ) && 
						( MC_ActionEntry_Boss.MC_BossAction_BG.getChildAt( testChildIndex ).name == bossActionBGName ) )	{
							//trace("**** onBackgroundImageLoaded deleting existing BG image " + assetImageBGName );
							MC_ActionEntry_Boss.MC_BossAction_BG.removeChildAt( testChildIndex );
							break;
					}
					
					++testChildIndex;
				}

				// Setup the new bmp image.
				//trace("set new image " + e.assetInfo );
				var asset:AssetImage = e.assetInfo as AssetImage;
				var bmp:Bitmap = new Bitmap( asset.content.bitmapData );
				//trace("set new image bmp " + bmp );				
				bmp.name = bossActionBGName;
				// TODO: Fix these hard coded amounts when the action bg images are re-sized properly
				//bmp.y = -78.5;
				bmp.height = 210.0;//bmp.height = 314.65;
				bmp.width = 557.25;
				//bmp.height = MC_ActionEntry_Boss.MC_BossAction_BG.height;
				//bmp.width = MC_ActionEntry_Boss.MC_BossAction_BG.width;
				// Add the bg as a child image.
				MC_ActionEntry_Boss.MC_BossAction_BG.addChild( bmp );
				//trace("**** onBackgroundImageLoaded set image to " + assetImageBGName );
				
				// Remove the listener
				Main.assetMgr.removeEventListener( AssetManagerEvent.ASSET_LOAD_COMPLETE, onBackgroundImageLoaded );
				Main.assetMgr.removeEventListener( AssetManagerErrorEvent.ASSET_LOAD_ERROR, onBackgroundImageError );
			}
		}

		/** 
		 * Handle Image loading error.
		 * */
		private function onBackgroundImageError( e:AssetManagerErrorEvent ):void 
		{
			//trace("**** onBackgroundImageError for " +  _currentBossActionObj.details_image );
			
			if( _currentBossActionObj && e.assetInfo.url.indexOf( _currentBossActionObj.details_image ) == -1 ){				
				return;
			}
			
			Main.assetMgr.removeEventListener( AssetManagerEvent.ASSET_LOAD_COMPLETE, onBackgroundImageLoaded );
			Main.assetMgr.removeEventListener( AssetManagerErrorEvent.ASSET_LOAD_ERROR, onBackgroundImageError );
		}

		/** 
		 * Update the boss action progress bar.
		 * */
		private function updateBossActionProgressBar():void {
			
			if ( _currentBossActionObj == null ) {
				trace("updateBossActionProgressBar FAILED because  _currentBossActionObj == null ");
				return;
			}

			if ( _currentBossActionObj.level >= 2 ) {
				_bossActionProgressBar.progress = 1;
			}
			else if ( _currentBossActionObj.next_level_xp != undefined ) {
				//trace("  _currentBossActionObj.xp: " + _currentBossActionObj.xp);
				//trace("  _currentBossActionObj.next_level_xp: " + _currentBossActionObj.next_level_xp);
				_bossActionProgressBar.progress = parseFloat( _currentBossActionObj.xp ) / parseFloat( _currentBossActionObj.next_level_xp );
			}
			else {
				_bossActionProgressBar.progress = 0;
			}
			
			//trace("  _progressBar.progress: " + _bossActionProgressBar.progress);
		}

		/** 
		 * Add event listeners for boss action hover, click, etc.
		 * */
		private function addBossActionListeners():void {
			
			MC_ActionEntry_Boss.addEventListener( MouseEvent.ROLL_OVER, onBossDescriptionRollOver );
			MC_ActionEntry_Boss.addEventListener( MouseEvent.ROLL_OUT, onBossDescriptionRollOut );
			
			MC_ActionEntry_Boss.BTN_ActivateAction.addEventListener( MouseEvent.ROLL_OVER, onDoBossActionRollover );
			MC_ActionEntry_Boss.BTN_ActivateAction.addEventListener( MouseEvent.ROLL_OUT, onDoBossActionRollout );
			MC_ActionEntry_Boss.BTN_ActivateAction.addEventListener( MouseEvent.CLICK, onDoBossActionClick );
			
			MC_ActionEntry_Boss.MC_Lock.addEventListener( MouseEvent.ROLL_OVER, onBossLockRollover );
			MC_ActionEntry_Boss.MC_Lock.addEventListener( MouseEvent.ROLL_OUT, onBossLockRollout );
			
			MC_ActionEntry_Boss.MC_InvestmentHolder_1.addEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_2.addEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_3.addEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_4.addEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_5.addEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_6.addEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			
			Main.gs.addEventListener( GameStateEvent.ENERGY_TICK, updateBossActionForEnergyTick );
			
		}

		/** 
		 * Remove event listeners for boss action hover, click, etc.
		 * */
		private function removeBossActionListeners():void {
			
			MC_ActionEntry_Boss.removeEventListener( MouseEvent.ROLL_OVER, onBossDescriptionRollOver );
			MC_ActionEntry_Boss.removeEventListener( MouseEvent.ROLL_OUT, onBossDescriptionRollOut );

			MC_ActionEntry_Boss.BTN_ActivateAction.removeEventListener( MouseEvent.ROLL_OVER, onDoBossActionRollover );
			MC_ActionEntry_Boss.BTN_ActivateAction.removeEventListener( MouseEvent.ROLL_OUT, onDoBossActionRollout );
			MC_ActionEntry_Boss.BTN_ActivateAction.removeEventListener( MouseEvent.CLICK, onDoBossActionClick );

			MC_ActionEntry_Boss.MC_Lock.removeEventListener( MouseEvent.ROLL_OVER, onBossLockRollover );
			MC_ActionEntry_Boss.MC_Lock.removeEventListener( MouseEvent.ROLL_OUT, onBossLockRollout );

			MC_ActionEntry_Boss.MC_InvestmentHolder_1.removeEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_2.removeEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_3.removeEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_4.removeEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_5.removeEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			MC_ActionEntry_Boss.MC_InvestmentHolder_6.removeEventListener( MouseEvent.CLICK, handleInvestmentsClick );
			
			Main.gs.removeEventListener( GameStateEvent.ENERGY_TICK, updateBossActionForEnergyTick );
		}

		/** 
		 * Process the boss action Go! click.
		 * */
		private function onDoBossActionClick(e:MouseEvent):void
		{
			//dispatchEvent( new ActionEvent(ActionEvent.PERFORM_ACTION_REQUEST, _data, true ) );
			Main.soundMgr.playSound( SocialNetworkConfig.serverHost + Main.SOUND_URL + "Click_Medium.mp3" );
			_actionsPage.performAction( _bossActionID );
		}
		
		/** 
		 * Show boss action Go! tooltip
		 * */
		private function onDoBossActionRollover( e:MouseEvent ):void 
		{
			var text:String = "Do this action!";
			Main.tooltipMgr.showTooltip( text, stage.mouseX, stage.mouseY + 10, 0.3, 10 );
		}

		/** 
		 * Hide boss action Go! tooltip
		 * */
		private function onDoBossActionRollout( e:MouseEvent ):void 
		{
			Main.tooltipMgr.hideTooltip();
		}

		/** 
		 * Show boss action Locked tooltip
		 * */
		private function onBossLockRollover( e:MouseEvent ):void 
		{
			Main.tooltipMgr.showTooltip( _bossActionLockReason, stage.mouseX, stage.mouseY + 10, 0.3, 10 );
		}

		/** 
		 * Hide boss action Locked tooltip
		 * */
		private function onBossLockRollout( e:MouseEvent ):void 
		{
			Main.tooltipMgr.hideTooltip();
		}
		
		/** 
		 * Roll out the boss description.
		 * */
		private function onBossDescriptionRollOver( e:Event ) {
			MC_ActionEntry_Boss.MC_BossDescription.gotoAndPlay("inactive");
			MC_ActionEntry_Boss.MC_BossDescription.addEventListener( Event.ENTER_FRAME, stopShowDescription );	
		}
		
		/** 
		 * Callback to pause the description rollout animation at 'active'
		 * */
		private function stopShowDescription( evt:Event ):void {
			if ( MC_ActionEntry_Boss.MC_BossDescription.currentFrameLabel == "active" ) {
				MC_ActionEntry_Boss.MC_BossDescription.stop();
				MC_ActionEntry_Boss.MC_BossDescription.removeEventListener( Event.ENTER_FRAME, stopShowDescription );	
			}
		}
		
		/** 
		 * Hide the boss action description.
		 * */
		private function  onBossDescriptionRollOut( e:Event ) {
			MC_ActionEntry_Boss.MC_BossDescription.gotoAndPlay("active");
			MC_ActionEntry_Boss.MC_BossDescription.addEventListener( Event.ENTER_FRAME, stopHideDescription );	
		}

		/** 
		 * Callback to pause description rollout animation at 'inactive'
		 * */
		private function stopHideDescription( evt:Event ):void {
			if ( MC_ActionEntry_Boss.MC_BossDescription.currentFrameLabel == "inactive" ) {
				MC_ActionEntry_Boss.MC_BossDescription.stop();
				MC_ActionEntry_Boss.MC_BossDescription.removeEventListener( Event.ENTER_FRAME, stopHideDescription );	
			}
		}
		
		/** 
		 * Populates the boss action text.
		 * */
		public function updateBossActionText():void {
				
			if( _currentBossActionObj == null ){
				trace("No boss action for Tab " + (_currentTab) + " tier " + (_currentTier)  + " hiding boss action mc" );
				MC_ActionEntry_Boss.visible = false;
				return;
			}
			
			var career:Object = Main.gs.getActiveCareer();
			var energyCost:int = 0;
			if ( career.career_id == Enums.CAREER_ID_PRODUCER ) {
				energyCost = int(_currentBossActionObj.energy_cost) - Math.round(int(_currentBossActionObj.energy_cost) * int(career.current_level) * int(career.bonus_percent) / 100 );
			}else{
				energyCost = int( _currentBossActionObj.energy_cost );
			}
				
			//MC_ActionEntry_Boss.TXT_ActionName.text = _currentBossActionObj.title;
			MC_ActionEntry_Boss.TXT_ActionName.htmlText = '<b>' + _currentBossActionObj.title.replace("\&#A9", "©") + '</b>';
			MC_ActionEntry_Boss.TXT_Cost.text = String( energyCost );
			var cashString:String = _currentBossActionObj.cash_cost;
			if( _currentBossActionObj.cash_cost >= 1000000 ){
				cashString = String( _currentBossActionObj.cash_cost / 1000000 ) + "m";
			}
			else if( _currentBossActionObj.cash_cost >= 1000 ){
				cashString = String( _currentBossActionObj.cash_cost / 1000 ) + "k";
			}
			
			var reqsCount:int = 0;
			if ( _currentBossActionObj.cash_cost > 0 ) {
				MC_ActionEntry_Boss.MC_Requirement_Stat_1.TXT_Label.text = cashString;
				MC_ActionEntry_Boss.MC_Requirement_Stat_1.MC_Icon.gotoAndStop( "cash" );
				MC_ActionEntry_Boss.MC_Requirement_Stat_1.visible = true;
				++reqsCount;
			}
			if ( _currentBossActionObj.career_level_required > 0 ) {
				var careerName:String = Utility.convertCareerIdToName( _currentBossActionObj.career_id );
				if( reqsCount > 0 ){
					MC_ActionEntry_Boss.MC_Requirement_Stat_2.TXT_Label.text = careerName + " " + _currentBossActionObj.career_level_required;
					MC_ActionEntry_Boss.MC_Requirement_Stat_2.MC_Icon.gotoAndStop( "career_xp" );
					MC_ActionEntry_Boss.MC_Requirement_Stat_2.visible = true;
				}
				else {
					MC_ActionEntry_Boss.MC_Requirement_Stat_1.TXT_Label.text = careerName + " " + _currentBossActionObj.career_level_required;
					MC_ActionEntry_Boss.MC_Requirement_Stat_1.MC_Icon.gotoAndStop( "career_xp" );
					MC_ActionEntry_Boss.MC_Requirement_Stat_1.visible = true;
				}
				
				++reqsCount;
			}
			
			if( reqsCount < 1 ){
				MC_ActionEntry_Boss.MC_Requirement_Stat_1.visible = false;
				MC_ActionEntry_Boss.MC_Requirement_Stat_2.visible = false;
			}
			else if( reqsCount < 2 ){
				MC_ActionEntry_Boss.MC_Requirement_Stat_2.visible = false;
			}
			
			MC_ActionEntry_Boss.MC_BossDescription.bossDesc_anim.TXT_bossDesc.text = _currentBossActionObj.description;
		}
		
		/**
		 * Helper function for grouping boss action item data into a single object for easier display.
		 * */
		private function getBossActionReqsObject( bossObj:Object, itemIndex:int ) :Object{
			
			var singleItemData:Object = new Object();
				
			if( bossObj != null ){
				switch( itemIndex ) {
					case 0:
						singleItemData.item_required = bossObj.item1_required;
						singleItemData.item_amount = bossObj.item1_amount;
						break;
					case 1:
						singleItemData.item_required = bossObj.item2_required;
						singleItemData.item_amount = bossObj.item2_amount;
						break;
					case 2:
						singleItemData.item_required = bossObj.item3_required;
						singleItemData.item_amount = bossObj.item3_amount;
						break;
					case 3:
						singleItemData.item_required = bossObj.item4_required;
						singleItemData.item_amount = bossObj.item4_amount;
						break;
					case 4:
						singleItemData.item_required = bossObj.item5_required;
						singleItemData.item_amount = bossObj.item5_amount;
						break;
					case 5:
						singleItemData.item_required = bossObj.item6_required;
						singleItemData.item_amount = bossObj.item6_amount;
						break;
				}

				// Fill in name and amount owned for item requirements
				if ( singleItemData.item_required > 0 ) {
					var itemData:Object = Main.gs.getCatalogItemByID( singleItemData.item_required );
					//trace("itemData for itemID " + singleItemData.item_required + " " + itemData );
					if( itemData ){
						singleItemData.item_name = itemData.name;
					}
					else {
						singleItemData.item_name = "";
					}
					
					var playerItem:Object = Main.gs.getInventoryItemByCatalogID( singleItemData.item_required );
					//trace("playerItem for itemID " + singleItemData.item_required + " " + playerItem );
					if ( playerItem ) {
						singleItemData.player_amount = playerItem.quantity;
					}
					else {
						singleItemData.player_amount = 0;
					}
				}
			}
			
			return singleItemData;
		}
		
		/**
		 *	Set up the boss action requirement icons and text based on the users inventory and other stats. 
		 */
		public function updateBossActionRequirements():Boolean {

			var requirementsMet:Boolean = true;
			
			if( _currentBossActionObj == null ){
				trace("No boss action for Tab " + (_currentTab) + " tier " + (_currentTier)  + " hiding boss action mc" );
				MC_ActionEntry_Boss.visible = false;
				return false;
			}
			
			// Loop through MCs and fill data that is availalbe.
			var itemReqsCount:int = 0;
			var reqMCIndex:int = 0;
			while ( reqMCIndex < NUM_BOSS_ACTION_ITEM_REQS ) {
				
				var singleItemReq:Object = getBossActionReqsObject( _currentBossActionObj, reqMCIndex ) ;
				if( singleItemReq != null ){
					// Hide MC by default
					_bossActionReqMCsArray[reqMCIndex].visible = false;

					// Item ID specified as required
					if (  singleItemReq.item_required > 0 ) {
						
						_bossActionReqMCsArray[reqMCIndex].visible = true;
						// Enforce that the amount is > 0, an item is specified, an amount < 1 is an error in the database.
						var tempAmount:int = ( singleItemReq.item_amount > 0 ) ? singleItemReq.item_amount : 1;
						// Verify the player has the item and amount.
						if ( ActionUtility.checkRequiredItemForAction( singleItemReq.item_required, 0, tempAmount ) ) {
							_bossActionReqMCsArray[reqMCIndex].gotoAndStop("haveItem");
						}
						else {
							_bossActionReqMCsArray[reqMCIndex].gotoAndStop("needItem");
							requirementsMet = false;
							_bossActionLockReason = "Requires " + singleItemReq.item_name;
						}
						
						// Set the name and amount text details
						var requiredAmount:String = "";
						if( singleItemReq.item_amount > 1 ) {
							requiredAmount = " x" + singleItemReq.item_amount;
						}
						_bossActionReqMCsArray[reqMCIndex].TXT_Label.text = singleItemReq.item_name + requiredAmount;
						_bossActionReqMCsArray[reqMCIndex].TXT_Amt.text = singleItemReq.player_amount;	
						
					}
					else {
						// count the # of required items skipped so we can scale the BG appropriately
						++itemReqsCount;
					}
				}
				
				++reqMCIndex;
			}
			
			// Set the size of the BG container to match the # of displayed item requirements.
			// Full BG height is 170.10 tall
			MC_ActionEntry_Boss.MC_ItemReqs_BG.height = BOSS_ACTION_ITEM_REQ_BG_HEIGHT;
			
			// Each entry is 22.5 tall, but they overlap, so subtract a relative height.  
			var bgHeightAdjIndex:int = 0;
			while( bgHeightAdjIndex < itemReqsCount ){
				MC_ActionEntry_Boss.MC_ItemReqs_BG.height -= BOSS_ACTION_ITEM_REQ_ENTRY_HEIGHT;
				++bgHeightAdjIndex;
			}
			
			var career:Object = Main.gs.getActiveCareer();
			var energyCost:int = 0;
			if ( career.career_id == Enums.CAREER_ID_PRODUCER ) {
				energyCost = int(_currentBossActionObj.energy_cost) - Math.round(int(_currentBossActionObj.energy_cost) * int(career.current_level) * int(career.bonus_percent) / 100 );
			}else{
				energyCost = int( _currentBossActionObj.energy_cost );
			}

			if ( requirementsMet ) {
				if( parseInt( Main.gs.userCore.energy ) < energyCost ){
					requirementsMet = false;
					_bossActionLockReason = "Requires " + energyCost +" energy";
				}
				else if (( parseInt( _currentBossActionObj.cash_cost ) > 0 )  &&  ( parseInt( _currentBossActionObj.cash_cost)  > Main.gs.cash ) ){
					// Not enough cash
					requirementsMet = false;
					_bossActionLockReason = "Requires " + parseInt( _currentBossActionObj.cash_cost) +" cash";
				}
				else if ( int(Main.gs.getActiveCareer().current_level ) < int( _currentBossActionObj.career_level_required ) ){
					// Not high enough career level.
					requirementsMet = false;
					var careerName:String = Utility.convertCareerIdToName( _currentBossActionObj.career_id );
					_bossActionLockReason = careerName + " " + _currentBossActionObj.career_level_required;
				}
			}
			
			return requirementsMet;
		}

		/**
		 * Test the requirements and 
		 * */
		public function testBossActionAvailable():void {

			// Update progress.
			updateBossActionProgressBar();
			
			// Updated requirement display and test for 
			var bossActionAvailable:Boolean = updateBossActionRequirements();

			if( Main.gs.actionListDisplayMode == Enums.ACTIONS_DISPLAY_MODE_CAREERS ){
				// if we are displaying a career tab that is not the current active career it is not available
				var activeCareerID:int = Main.gs.getActiveCareer().career_id;
				var tempTabs:Array = Main.gs.getActionTabTiers();
				
				if ( tempTabs[ _currentTabDataIndex - 1 ].career_id != activeCareerID ) {
					bossActionAvailable = false;
					_bossActionLockReason = "Requires the " + Utility.convertCareerIdToName( tempTabs[ _currentTabDataIndex - 1 ].career_id ) + " career";
				}
			}
			
			// Toggle the 'Go' and 'Lock' buttons.
			if( bossActionAvailable ){
				MC_ActionEntry_Boss.BTN_ActivateAction.visible = true;
				MC_ActionEntry_Boss.BTN_ActivateAction.buttonMode = true;	
				MC_ActionEntry_Boss.BTN_ActivateAction.mouseEnabled = true;
				MC_ActionEntry_Boss.BTN_ActivateAction.useHandCursor = true;
				MC_ActionEntry_Boss.MC_Lock.visible = false;
				//Tweener.addTween( MC_ActionEntry_Boss.MC_ProgressBar, { time: 0.3, _hue: 0 } );
				if ( _currentBossActionObj.level < 2 ) {
					// Set the bar blue
					Tweener.addTween( MC_ActionEntry_Boss.MC_ProgressBar, { time: 0.3, _hue: 0 } );
				}
				else {
					// Turn the bar green
					Tweener.addTween( MC_ActionEntry_Boss.MC_ProgressBar, { time: 0.3, _hue: 270 } );
				}
			}
			else{
				MC_ActionEntry_Boss.BTN_ActivateAction.visible = false;
				MC_ActionEntry_Boss.BTN_ActivateAction.buttonMode = false;					
				MC_ActionEntry_Boss.BTN_ActivateAction.mouseEnabled = false;
				MC_ActionEntry_Boss.BTN_ActivateAction.useHandCursor = false;
				MC_ActionEntry_Boss.MC_Lock.visible = true;
				
				Tweener.addTween( MC_ActionEntry_Boss.MC_ProgressBar, { time: 0.3, _hue: 180 } );				
			}
		}
		
		/** 
		 * Finds the tab id the user should start the screen on.
		 * */
		private function getStartingTab():int {

			// Start on the active career if the page was opened in career display mode
			if ( Main.gs.actionListDisplayMode == Enums.ACTIONS_DISPLAY_MODE_CAREERS ) {

				var career:Object = Main.gs.getActiveCareer();
				if( career != null ){
					var tempTabs:Array = new Array();
					tempTabs = Main.gs.getActionTabTiers();
					var tabData:Object = null;
					for each( tabData in tempTabs ) {
				
						if ( tabData.career_id == career.career_id ) {
							//trace("__ returning getStartingTab " + tabData.att_id);
							return tabData.att_id;
						}
					}
				}
			}	

			// All else display the first tab.
			//trace("__ returning default getStartingTab");
			return 1;
		}
				
		/**
		 * Helper funciton to find the action_tier_level of a selected tab.
		 * */
		private function getUserActionTierLevelByTabID( tabID:int ) {
			
			//trace("getUserActionTierLevelByTabID for tabID " + tabID );
			
			var tierData:Object = null;
			var userTiersObject:Object = Main.gs.userActionTierLevels;
			for each( tierData in userTiersObject.contents ) {
				if ( tierData.action_tab_tier_id == tabID ) {
					return tierData.action_tier_level;
				}
			}
			
			trace("ERROR default returning 1 from getUserActionTierLevelByTabID" );
			return 1;
		}

		/** 
		 * Overriddes list class function to scroll elements that are related to the list, but not a list entry. (Boss Action entry)
		 * */
		override public function scrollChildren( moveY:Number = 0.0, moveX:Number = 0.0 ):void {
			//trace("scrollChildren " + moveY + " " + moveX );
			//MC_ActionEntry_Boss.y += moveY;
			//MC_ActionEntry_Boss.x += moveX;
		}

		/**
		 * Update the action for energy changes
		 * */
		private function updateBossActionForEnergyTick( e:GameStateEvent ):void {
			testBossActionAvailable();
		}
	
		
		override public function update():void
		{
			var i:int;
			var currCell:IListItem;
			
			// Create more cells if we need them
			if (_data.length > _cells.length) {
				for (i = _cells.length; i < _data.length; ++i) {
					currCell = new _cellClass();
					MC_Holder.addChild(currCell.clip);
					_cells.push(currCell);
				}
			}
			
			// Populate the cells
			for (i = 0; i < _data.length; ++i) {
				currCell = _cells[i] as IListItem;
				currCell.data = _data[i];
				currCell.clip.visible = true;
				if(_isVerticalList){
					currCell.clip.y = i * _cellHeight;
				}else{
					currCell.clip.x = i * _cellWidth;
				}
				if (currCell.clip.parent != MC_Holder) {
					MC_Holder.addChild(currCell.clip);
				}
			}
			
			// Hide extra cells
			for (i; i < _cells.length; ++i) {
				//trace("Hiding cell " + i);
				currCell = _cells[i] as IListItem;
				if (currCell.clip.parent != MC_Holder) {
					continue;
				}
				//currCell.clip.visible = false;
				currCell.clip.y = 0;
				MC_Holder.removeChild(currCell.clip);
			}
			
			// Adjust the scroller
			if (MC_Holder.height > MC_Mask.height) {
				//trace("Scroller should be enabled");
				if (!MC_Scroller.isEnabled) {
					MC_Scroller.enable();
					MC_Scroller.addEventListener(SliderEvent.SCROLL, onScroll);
				}
				
				var percent:Number;
				if(_isVerticalList){
					percent = (MC_Holder.y - _holderBaseY) / (MC_Mask.height - MC_Holder.height);
				}else{
					percent = (MC_Holder.x - _holderBaseX) / (MC_Mask.width - MC_Holder.width);
				}
				if (percent > 1) {
					percent = 1;
				}
				else if (percent < 0) {
					percent = 0;
				}
				MC_Scroller.percentage = percent;
			}
			else {
				if(_isVerticalList){
					MC_Holder.y = _holderBaseY;
				}else{
					MC_Holder.x = _holderBaseX;
				}
				MC_Scroller.disable();
				MC_Scroller.removeEventListener(SliderEvent.SCROLL, onScroll);
			}
		}

		override public function onScroll(e:SliderEvent):void
		{
			if (_isVerticalList) {
				
				var preScrollY = MC_Holder.y;
				
				// Scroll to the new Y
				MC_Holder.y = _holderBaseY - (MC_Holder.height - MC_Mask.height) * e.percentage;
				
				// Pass the data to any related child elements
				var moveY:Number = MC_Holder.y - preScrollY;
				scrollChildren( moveY, 0 );
			}else {
				var preScrollX = MC_Holder.x;
				
				// Scroll to the new X
				MC_Holder.x = _holderBaseX - (MC_Holder.width - MC_Mask.width) * e.percentage;
				
				// Pass the data to any related child elements
				var moveX:Number = MC_Holder.x - preScrollX;
				scrollChildren( 0, moveX );
			}
		}

		
		/** 
		 * 
		 * */
		private function handleInvestmentsClick( e:MouseEvent ):void{

			//trace("handleInvestmentsClick ");

			var popup:IPopup = null;
			var singleItemReq:Object = null;
		
			//trace("e.target " + e.target.name);
			//trace("e.target.parent " + e.target.parent.name);
			
			if ( e.target.parent.name == "MC_InvestmentHolder_1" ) {
				singleItemReq = getBossActionReqsObject( _currentBossActionObj, 0 ) ;
			}
			else if ( e.target.parent.name == "MC_InvestmentHolder_2" ) {
				singleItemReq = getBossActionReqsObject( _currentBossActionObj, 1 ) ;
			}
			else if ( e.target.parent.name == "MC_InvestmentHolder_3" ) {
				singleItemReq = getBossActionReqsObject( _currentBossActionObj, 2 ) ;
			}
			else if ( e.target.parent.name == "MC_InvestmentHolder_4" ) {
				singleItemReq = getBossActionReqsObject( _currentBossActionObj, 3 ) ;
			}
			else if ( e.target.parent.name == "MC_InvestmentHolder_5" ) {
				singleItemReq = getBossActionReqsObject( _currentBossActionObj, 4 ) ;
			}
			else if ( e.target.parent.name == "MC_InvestmentHolder_6" ) {
				singleItemReq = getBossActionReqsObject( _currentBossActionObj, 5 ) ;
			}
			else {
				return;
			}

			var itemData:Object = Main.gs.getCatalogItemByID( singleItemReq.item_required );				
			if( itemData ){
				popup = new ActionMiniStorePopup( itemData, '', '' );
				MovieClip(popup).addEventListener(ActionEvent.MINI_STORE_PURCHASE, handleMiniStorePurchase);
				MovieClip(popup).addEventListener(ActionEvent.MINI_STORE_CLOSE, handleMiniStoreClose);
				Main.popupMgr.queuePopup( popup );	
			}
		}
		
		private function handleMiniStorePurchase(event:ActionEvent):void
		{
			//trace("handleMiniStorePurchase");
			event.target.removeEventListener(ActionEvent.MINI_STORE_PURCHASE, handleMiniStorePurchase);
			event.target.removeEventListener(ActionEvent.MINI_STORE_CLOSE, handleMiniStoreClose);
			Main.showWaitingPopup();
			var cmd:NetCommand = new NetCommand( new PurchaseOfferCommandData( int(event.data.offer_id), 1 ) );
			Main.netMgr.addEventListener("offersPurchaseSuccess", onPurchaseSuccess);
			Main.netMgr.addEventListener("offersPurchaseFailure", onPurchaseFail);
			Main.netMgr.netInt.sendNetCommand(cmd);
		}
		
		private function handleMiniStoreClose(event:ActionEvent):void
		{
			//trace("handleMiniStoreClose");
			event.target.removeEventListener(ActionEvent.MINI_STORE_PURCHASE, handleMiniStorePurchase);
			event.target.removeEventListener(ActionEvent.MINI_STORE_CLOSE, handleMiniStoreClose);
		}
		
		private function onPurchaseSuccess(e:NetworkInterfaceEvent):void
		{
			Main.netMgr.removeEventListener("offersPurchaseSuccess", onPurchaseSuccess);
			Main.netMgr.removeEventListener("offersPurchaseFailure", onPurchaseFail);
			Main.hideWaitingPopup();
			
			var p:IPopup = new GeneralPopup("Item Purchased", "You have successfully purchased\n" + Main.gs.getCatalogItemByID(e.data.data.item_id).name + "", Enums.POPUP_ICON_ITEM);
			//Main.popupMgr.closeCurrentPopup();
			Main.popupMgr.queuePopup(p);
			
			Main.soundMgr.playSound( SocialNetworkConfig.serverHost + Main.SOUND_URL + "Alert_GiftReceipt.mp3" );
			
			// Reset the boss data.
			setupBossAction();
		}
		
		private function onPurchaseFail(e:NetworkInterfaceEvent):void
		{
			Main.netMgr.removeEventListener("offersPurchaseSuccess", onPurchaseSuccess);
			Main.netMgr.removeEventListener("offersPurchaseFailure", onPurchaseFail);
			
			var p:IPopup = new GeneralPopup("Failure", "There was an error purchasing that item.");
			Main.hideWaitingPopup();
			Main.popupMgr.queuePopup(p);
		}

	}

	
}