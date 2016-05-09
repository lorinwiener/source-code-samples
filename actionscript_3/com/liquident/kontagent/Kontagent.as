//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  Kontagent.as
//
//  © 2010 Liquid Entertainment
//
//  Description:
//   AssetXML description
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

package com.liquident.kontagent
{
	import com.liquident.GameState;
	import com.liquident.Utility;
	import com.liquident.networkinterface.NetCommand;
	import com.liquident.networkinterface.netcommanddata.KontagentInstallSent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	
	public class Kontagent
	{
		private static var _instance:Kontagent;
		
		// LIVE SERVER
		//public static const kontagentURL:String = "http://test-server.kontagent.net/api/v1/e18b8df8bb0640699e73d525792c4609/";
		public static const kontagentURL:String = "https://api.geo.kontagent.net/api/v1/e18b8df8bb0640699e73d525792c4609/";
		
		// TEST SERVER
		//public static const kontagentURL:String = "http://test-server.kontagent.net/api/v1/62fb6e4c0d644667952667059101337f/";
		//public static const kontagentURL:String = "https://api.geo.kontagent.net/api/v1/62fb6e4c0d644667952667059101337f/";
		
		// PIXEL TRACKING
		public static const adparlorInstallURL:String = "https://fbads.adparlor.com/conversion.php?adid=444";
		public static const adparlorTutorialCompleteURL:String = "https://fbads.adparlor.com/Engagement/action.php?id=171&adid=444&vars=7djDxM/P1uDV4OfKs7+ntJDixuXg0OTZ2MnR1tLkwNPS49fX2NTBydPl0+WmvcGR68vV1cXi1dHU3ufX7KCSjdnjxsXh0ayzyA=="; 
		public static const adparlorMonetizationURL:String = "https://fbads.adparlor.com/Engagement/action.php?id=170&adid=444&vars=7djDxM/P1uDV4OfKs7SxjdbV1ObN4ebE3NXXz9jPwtjg1OTE58XK0Nni1Ky6vp7X3tnWwtbkwNrb5OTYs5aO1tfVtOfOqcC0";
		
		public static const nanigansInstallURL:String = "https://api.nanigans.com/event.php?app_id=4152&type=install&name=main&user_id=";
		public static const nanigansTutorialCompleteURL:String = "https://api.nanigans.com/event.php?app_id=4152&type=user&name=tutorial&user_id=";
		public static const nanigansMonetizationURL:String = "https://api.nanigans.com/event.php?app_id=4152&type=purchase&name=main&user_id="
			
		public function Kontagent()
		{
			
		}
		
		public static function getInstance():Kontagent
		{
			if( _instance == null ) {
				_instance = new Kontagent();
			}
			
			return _instance;
		}
		
		public function createHexTag( userId:String, hexLength:int = 8 ):String
		{
			var hexString:String = "12345678";
			
			var myDate:* = new Date();
			var unixTime:String = Number( Math.round( myDate.getTime() / 1000 ) ).toString( 16 );
			
			hexString = Number( userId ).toString( 16 ) + unixTime;
			
			if( hexString.length > hexLength ) {
				hexString = hexString.slice( 0, hexLength );
			}
			else if( hexString.length < hexLength ) {
				for( var i:int = hexString.length; i < hexLength; i++ ) {
					hexString += "0";
				}
			}
			
			return hexString;
		}
		
		public function sendPageRequest():void
		{
			var url:String = kontagentURL;
			
			url += "pgr/?";
			
			var myDate:* = new Date();
			var unixTime:String = String( Math.round( myDate.getTime() / 1000 ) );
			
			url += "s=" + Main.gs.facebookID;
			url += "&ts=" + unixTime;
			
			ExternalInterface.call( 'sendKontagentMetric', url );
		}
		
		public function sendInstall( hexTag:String ):void
		{
			var cmd:NetCommand = new NetCommand( new KontagentInstallSent() );
			Main.netMgr.netInt.sendNetCommand(cmd);
			
			var urlParams:Object = Utility.readQueryString();
			
			var url:String = kontagentURL;
			
			url += "apa/?";
			
			url += "s=" + Main.gs.facebookID;
			
			if( urlParams["kt_type"] ) {
				var tag:String;
				
				tag = urlParams["kt_type"];
				
				if( urlParams["kt_st1"] ) {
					tag += urlParams["kt_st1"];
				}
				if( urlParams["kt_st2"] ) {
					tag += urlParams["kt_st2"];
				}
				if( urlParams["kt_st3"] ) {
					tag += urlParams["kt_st3"];
				}
				
				url += "&su=" + hexTag;
			}
			
			if( hexTag.length > 8 ) {
				url += "&u=" + hexTag;
			}
			
			ExternalInterface.call( 'sendKontagentMetric', url );
		}
		
		public function sendUCC():String
		{
			var cmd:NetCommand = new NetCommand( new KontagentInstallSent() );
			Main.netMgr.netInt.sendNetCommand(cmd);
			
			var urlParams:Object = Utility.readQueryString();
			
			var url:String = kontagentURL;
			var tag:String;
			
			if( urlParams["kt_type"] ) {
				url += "ucc/?";
				
				url += "s=" + Main.gs.facebookID;
				
				url += "&tu=" + urlParams["kt_type"];
				url += "&i=0";
				
				tag = urlParams["kt_type"];
			}
			else {
				return "";
			}
			
			if( urlParams["kt_st1"] ) {
				url += "&st1=" + urlParams["kt_st1"];
				
				tag += urlParams["kt_st1"];
			}
			if( urlParams["kt_st2"] ) {
				url += "&st2=" + urlParams["kt_st2"];
				
				tag += urlParams["kt_st2"];
			}
			if( urlParams["kt_st3"] ) {
				url += "&st3=" + urlParams["kt_st3"];
				
				tag += urlParams["kt_st3"];
			}
			
			var hexTag:String = createHexTag( Main.gs.facebookID );
			
			url += "&su=" + hexTag;
			
			ExternalInterface.call( 'sendKontagentMetric', url );
			
			return hexTag;
		}
		
		public function sendStreamPost( 
			userId:String,
			subtype1:String = null,
			subtype2:String = null,
			subtype3:String = null ):String
		{
			var url:String = kontagentURL;
			
			url += "pst/?";
			
			url += "s=" + Main.gs.facebookID;
			
			var tag:String = createHexTag( userId, 16 );
			url += "&u=" + tag;
			url += "&tu=stream";
			
			if( subtype1 ) {
				url += "&st1=" + subtype1;
			}
			if( subtype2 ) {
				url += "&st2=" + subtype2;
			}
			if( subtype3 ) {
				url += "&st3=" + subtype3;
			}
			
			ExternalInterface.call( 'sendKontagentMetric', url );
			
			return tag;
		}
		
		public function sendStreamPostResponse( 
			userId:String,
			install:String,
			hexTag:String,
			subtype1:String = null,
			subtype2:String = null,
			subtype3:String = null ):void
		{
			var url:String = kontagentURL;
			
			url += "psr/?";
			
			url += "r=" + Main.gs.facebookID;
			
			// I was told that this should always be 0 and then send the install after the response
			//url += "&i=" + install;
			url += "&i=0"
			url += "&u=" + hexTag;
			url += "&tu=stream";
			
			if( subtype1 ) {
				url += "&st1=" + subtype1;
			}
			if( subtype2 ) {
				url += "&st2=" + subtype2;
			}
			if( subtype3 ) {
				url += "&st3=" + subtype3;
			}
			
			ExternalInterface.call( 'sendKontagentMetric', url );
			
			if( install == "1" ) {
				sendInstall( hexTag );
			}
		}
		
		public function sendCustomEvent( 
			userId:String,
			eventName:String,
			eventValue:int = 0,
			eventLevel:int = 0,
			subtype1:String = null,
			subtype2:String = null,
			subtype3:String = null ):void
		{
			var url:String = kontagentURL;
			
			url += "evt/?";
			
			url += "s=" + userId;
			url += "&n=" + eventName;
			
			// Test for optional variables individually.
			if( eventValue > 0 ) {
				url += "&v=" + eventValue;
			}
			if( eventLevel > 0 ) {
				url += "&l=" + eventLevel;
			}
			if( subtype1 ) {
				url += "&st1=" + subtype1;
			}
			if( subtype2 ) {
				url += "&st2=" + subtype2;
			}
			if( subtype3 ) {
				url += "&st3=" + subtype3;
			}
			
			ExternalInterface.call( 'sendKontagentMetric', url );
		}
		
		public function sendFirstCareer( careerId:String ):void
		{
			sendCustomEvent( Main.gs.facebookID, careerId, 1, 0, "career_first" );
		}
		
		public function sendCareerChange( userLevel:int, careerId:String ):void
		{
			sendCustomEvent( Main.gs.facebookID, careerId, 1, userLevel, "career_change" );
		}
		
		public function sendTutorialButtonClick( userId:String, tutorialName:String, buttonId:String ):void
		{
			sendCustomEvent( Main.gs.facebookID, buttonId, 1, 0, tutorialName );
		}
		
		// AD PARLOR Messages, separate from Kontagent
		public function sendAdparlorInstall():void
		{
			//ExternalInterface.call( 'sendKontagentMetric', adparlorInstallURL );
			
			//var url:String = nanigansInstallURL + Main.gs.facebookID;
			//ExternalInterface.call( 'sendKontagentMetric', url );
		}
		
		public function sendAdparlorTutorialComplete():void
		{
			ExternalInterface.call( 'sendKontagentMetric', adparlorTutorialCompleteURL );
			
			var url:String = nanigansTutorialCompleteURL + Main.gs.facebookID;
			ExternalInterface.call( 'sendKontagentMetric', url );
		}
		
		public function sendAdparlorMonetization( amount:int ):void
		{
			ExternalInterface.call( 'sendKontagentMetric', adparlorMonetizationURL );
			
			var url:String = nanigansMonetizationURL + Main.gs.facebookID + "&value=" + amount;
			ExternalInterface.call( 'sendKontagentMetric', url );
		}
	}
}