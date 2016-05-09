package com.liquident.monetization
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.liquident.GameState;
	import com.liquident.GameStateEvent;
	import com.liquident.Metrics.MetricsManager;
	import com.liquident.NetworkManager;
	import com.liquident.SoundManager;
	import com.liquident.adventurepage.GridMgr;
	import com.liquident.assetmanager.DNDAssetManager;
	import com.liquident.charcreationpage.MovieClipButton;
	import com.liquident.charcreationpage.TextDefinitions;
	import com.liquident.networkinterface.NetworkInterface;
	import com.liquident.popups.BasicPopup;
	import com.liquident.popups.PopupManager;
	import com.liquident.ui.HBox;
	import com.liquident.ui.SimpleSelectable;
	import com.liquident.ui.SingleSelectButtonGroup;
	import com.liquident.ui.VBox;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	
	import pages.IndexPage;

	public class CurrencyPurchaseController extends BasicPopup
	{
		private var _asset:MovieClip;
		private var _headerField:TextField;
		private var _descriptionField:TextField;
		private var _purchaseItemField:TextField;
		private var _legalField:TextField;
		private var _offerHolderMC:MovieClip;
		private var _continueButton:MovieClipButton;
		private var _closeButton:SimpleButton
		private var _bg:MovieClip;
		private var _blocker:MovieClip;
		private var _trialPayDealSpotOfferHolderMC:MovieClip;
		private var _dealSpotLoader:Loader;
		private var _dealSpot:Object
		private var _isDealSpotLoaded:Boolean;
		
		private var _offerClipDictionary:Dictionary;
		private var _offerButtonGroup:SingleSelectButtonGroup;
		
		private var _assetOffsetX:Number;
		
		public function show():void
		{
			PopupManager.getInstance().queuePopup( this );
		}
		
		public function CurrencyPurchaseController(asset:MovieClip)
		{
			_asset = asset;
			_bg = _asset.MC_BG;
			_blocker = _asset.MC_Blocker;
			_headerField = _asset.TXT_Header;
			_descriptionField = _asset.TXT_Description;
			_purchaseItemField = _asset.TXT_Info;
			_legalField = _asset.TXT_Legal;
			_offerHolderMC = _asset.MC_Holder;
			_continueButton = new MovieClipButton(_asset.BTN_Continue, _asset.BTN_Continue.TXT_Label, onContinueClick);
			_closeButton = _asset.BTN_Exit;
			_trialPayDealSpotOfferHolderMC = _asset.MC_Holder_Dealspot;
			
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			
			_offerClipDictionary = new Dictionary();
			
			_isDealSpotLoaded = false;
			
			update();
			
			super(_asset);
		}
		
		public function populateOffers(offers:Array):void
		{
			if (!_offerButtonGroup) {
				_offerButtonGroup = new SingleSelectButtonGroup([]);
			}
			
			while (_offerHolderMC.numChildren > 0) {
				_offerHolderMC.removeChildAt(0);
			}
			
			var offerHBox:HBox = new HBox(3, HBox.ALIGN_TOP);
			
			var creditsPerDiamond:Number;
			for (var i:int = 0; i < offers.length; ++i) {
				var offer:Object = offers[i];
				
				// TODO: If there end up being gold offers, we'll need more processing here...
				if (i == 0) {
					creditsPerDiamond = offer.cost_amount / offer.award_amount;
				}
				
				var clip:MovieClip = DNDAssetManager.getInstance().getInstanceFromAsset("monetization.monetization", "OfferRowMC");
				clip.mouseChildren = false;
				
				clip.MC_BestValueSash.visible = false;
				
				var button:SimpleSelectable = new SimpleSelectable(clip, 1, 2);
				_offerButtonGroup.addButton(button);
				_offerClipDictionary[button] = offer;
				
				clip.TXT_AwardAmount.htmlText = "<b>" + "x" + offer.award_amount + "</b>";
				clip.TXT_CostAmount.htmlText = "<b>" + offer.cost_amount + "</b>";
				
				var bonus:Number = Number(offer.award_amount) - Number(offer.cost_amount) / creditsPerDiamond;
				bonus = int(bonus * 100 / (Number(offer.cost_amount) / creditsPerDiamond) + 0.5);
				
				/*if (bonus != 0) {
					clip.TXT_SaleAmount.htmlText = "<b>" + offer.cost_amount + "</b>";
				}
				else {
					clip.TXT_SaleAmount.text = '';
					clip.MC_Crossout.visible = false;
				}*/
				
				var award:Number = Number(offer.award_amount);
				var cost:Number = Number(offer.cost_amount);
				var delta:Number = award - cost;
				var extraValue:Number = (delta/cost)*100;
				var extraValueRounded:Number = Math.round(extraValue);
				
				if (extraValueRounded != 0) {
					clip.TXT_ExtraValue.htmlText = String(extraValueRounded) + "% Extra!";
				} else {
					clip.TXT_ExtraValue.htmlText = "";
				}
				
				clip.MC_Diamond.gotoAndStop(offers.length - i);
				
				if (clip.TXT_BonusAmount) {
					clip.TXT_BonusAmount.visible = false;
				}
				
				if (i == offers.length - 1){
					clip.MC_BestValueSash.visible = true;	
				}
				
				offerHBox.addChild(clip);
			}
			
			_offerHolderMC.addChild(offerHBox);
			update();
		}
		
		public function populateTrialPayDealSpotOffers() : void
		{
			if (_isDealSpotLoaded == false) {
				_isDealSpotLoaded = true;
				var facebookUserId:String = NetworkManager.getInstance().netInt.socialNetworkUserId;
				var accessToken:String = NetworkManager.getInstance().netInt.accessToken;			
				var thirdPartyIdRequestURL:String = "https://graph.facebook.com/" + facebookUserId + "?fields=third_party_id&access_token=" + accessToken;
				var thirdPartyIdURLRequest:URLRequest = new URLRequest(thirdPartyIdRequestURL);
				var thirdPartyIdURLLoader:URLLoader = new URLLoader();
				thirdPartyIdURLLoader.addEventListener( Event.COMPLETE, onThirdPartyIdURLLoaderRequestComplete );
				thirdPartyIdURLLoader.load(thirdPartyIdURLRequest);
			}
		}
		
		private function onThirdPartyIdURLLoaderRequestComplete(event:Event) : void
		{			
			var thirdPartyIdURLLoader:URLLoader = URLLoader(event.target);
			thirdPartyIdURLLoader.removeEventListener( Event.COMPLETE, onThirdPartyIdURLLoaderRequestComplete );
			
			var json:Object = JSON.decode(thirdPartyIdURLLoader.data);
			var thirdPartyId:String = json.third_party_id;
			
			_dealSpotLoader = new Loader();
			
			var appId:String = IndexPage.fb_sig_app_id;			
			var dealSpotURLRequest:URLRequest = new URLRequest("http://assets.tp-cdn.com/static3/swf/dealspot.swf?app_id=" + appId + "&mode=fbpayments&sid=" + thirdPartyId + "&onTransact=my_ontransact&onOpen=customer_click&onClose=customer_close");
			
			_dealSpotLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onDealSpotLoaderComplete );
			_dealSpotLoader.load(dealSpotURLRequest);
		}
		
		private function onDealSpotLoaderComplete(event:Event) : void
		{	
			_dealSpot = event.target.content;			
			_dealSpot.addEventListener(MouseEvent.ROLL_OVER, onDealSpotRollOver);			
			_dealSpot.addEventListener(MouseEvent.ROLL_OUT, onDealSpotRollOut);
			
			_dealSpotLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onDealSpotLoaderComplete );
			
			_trialPayDealSpotOfferHolderMC.addChild(_dealSpotLoader);
		}
		
		private function onDealSpotRollOver(event:Event) : void
		{
			DisplayObject(_dealSpot).scaleX = 1.05;
			DisplayObject(_dealSpot).scaleY = 1.05;
			DisplayObject(_dealSpot).x -=	1.8;
			DisplayObject(_dealSpot).y -=	1.8;
			SoundManager.instance.playSound(SoundManager.instance.basePath+"assets/Audio/DnD_Interface/Interface_Button_Highlighted.wav.mp3");
		}
		
		private function onDealSpotRollOut(event:Event) : void
		{
			DisplayObject(_dealSpot).scaleX = 1;
			DisplayObject(_dealSpot).scaleY = 1;
			DisplayObject(_dealSpot).x +=	1.8;
			DisplayObject(_dealSpot).y +=	1.8;
		}
		
		public function updateDescriptionText(currBalance:int, purchaseName:String = null, purchasePrice:int = 0):void
		{
			var descText:String;
			
			if (purchaseName)
			{
				var needed:int = purchasePrice - currBalance;
				var plural:String = needed > 1 ? "s" : "";
				descText = TextDefinitions.getDialog("currency_prompt_description_text_for_item").replace("<COST>", needed).replace("<ITEM NAME>", purchaseName).replace("<PLURAL>", plural);
				_purchaseItemField.htmlText = descText;
			}
			else
			{
				// Q: Should this be hidden instead?
				descText = TextDefinitions.getDialog("currency_prompt_description_text_no_item");
				_purchaseItemField.htmlText = descText;
			}
		}
		
		private function update():void
		{
			if (_asset.stage) {
				reposition(false);
			}
		}
		
		public function get visible():Boolean
		{
			return _asset.visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_asset.visible = value;
		}
		
		public function onContinueClick(e:Event):void
		{
			if (!_offerButtonGroup.selection) {
				return;
			}
			
			var offer:Object = _offerClipDictionary[_offerButtonGroup.selection];
			if (!offer) {
				return;
			}
			
			MetricsManager.getInstance().trackClick("buy_diamonds_offer_clicked");
			GameState.gs.network.purchaseCreditOffer(int(offer.offer_id));
			GameState.gs.navPage.forceWindowed();
			
			dispatchEvent(new Event(Event.SELECT, true));
		}
		
		public function onCloseClick(e:Event):void
		{
			close();
		}
		
		public override function cleanup():void
		{
			/*
			Let's not clean these up, since it's a persistent popup.
			
			_offerButtonGroup.clear();
			_continueButton.cleanup();
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseClick);
			*/
		}

		
		public function reposition(isFullScreen:Boolean):void
		{
			var gridMgr:GridMgr = GameState.gs.gridMgr;
			
			if( isFullScreen ) {
				_asset.x = 0.5 * (_asset.stage.fullScreenWidth - _bg.width);
				_blocker.width = _asset.stage.fullScreenWidth;
				_blocker.height = _asset.stage.fullScreenHeight;
			} else if (gridMgr) {
				_asset.x = 0.5 * (gridMgr.view.width - _bg.width);
				_blocker.width = gridMgr.view.width;
				_blocker.height = gridMgr.view.height;
			}
			else {
				_asset.x = 0.5 * (_asset.stage.stageWidth - _bg.width);
				_blocker.width = _asset.stage.stageWidth;
				_blocker.height = _asset.stage.stageHeight;
			}
			_blocker.x = -_asset.x;
		}
	}
}
