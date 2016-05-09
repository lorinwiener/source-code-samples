package com.facecake.tryon.abstract.view
{
	
	import com.facecake.metrics.TrackingActionDescriptions;
	import com.facecake.metrics.TrackingActions;
	import com.facecake.tryon.controller.CustomizeProductController;
	import com.facecake.tryon.events.BitmapEvent;
	import com.facecake.tryon.events.TransitionEvent;
	import com.facecake.tryon.model.TryOnModel;
	import com.facecake.tryon.mvc.Model;
	import com.facecake.tryon.mvc.View;
	import com.facecake.tryon.view.CustomizeProductView;
	import com.facecake.utils.AMFPHP;
	import com.greensock.events.TransformEvent;
	import com.greensock.transform.TransformManager;
	import com.facecake.utils.PopUp;
	import com.tutsplus.tooltip.display.ToolTip;
	
	import fl.motion.Color;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Abstract View class for MVC architecture to handle the assets displayed on stage, the events they trigger, and the communication of the
	 * view with the model via the controller.
	 */
	public class AbstractCustomizeProductView extends View
	{
		
		protected static const PAGE_NAME:String = "Customize Product View";
		
		protected var _stage:Stage;		
		protected var _instance:MovieClip;
		protected var _config:XML;
		
		private var _amf:AMFPHP = AMFPHP.getInstance();
		
		protected var _bitmap:Bitmap;
		protected var _bitmapData:BitmapData;
		protected var _backButton:SimpleButton;
		protected var _nextButton:SimpleButton;
		
		protected var _photoHolderOffsetX:Number;
		protected var _photoHolderOffsetY:Number;
		protected var _photoHolderContentOffsetX:Number;
		protected var _photoHolderContentOffsetY:Number;
		
		protected var _photoOutlineTop:Number;
		protected var _photoOutlineBottom:Number;
		protected var _photoOutlineLeft:Number;
		protected var _photoOutlineRight:Number;
		
		protected var _photoHolder:MovieClip;
		protected var _photo:MovieClip;
		protected var _photoOutline:MovieClip;
		protected var _photoMask:MovieClip;
		protected var _productHolder:MovieClip;
		
		protected var _toolTip:ToolTip;
		
		protected var _lastButtonClicked:String;
		
		protected var _popup:PopUp;	
		
		/**
		 * Constructor for the view to create an application container MovieClip, application background, etc.
		 */
		public function AbstractCustomizeProductView (argModel:TryOnModel, argController:CustomizeProductController, argContainer:MovieClip)
		{
			
			super (argModel, argController, argContainer);
			
			trace("AbstractCustomizeProductView Instantiated");
			
			initialize(argModel, argContainer);
			
		}
		
		protected function initialize(argModel:TryOnModel, argContainer:MovieClip):void
		{
			container = argContainer;
			_stage = container.stage;
			_config = argModel.config;
			
			_lastButtonClicked = "";
			
			loadGraphics();
			
			loadLogo();
			
			configureGraphics();
			
			_popup = new PopUp();
			
			addEventListeners();
			
			resetTransition();
			
			transitionIn();
		}
		
		protected function loadGraphics():void
		{			
			_photoMask = _instance.photoMask;
			
			_photoOutline = _instance.photoOutline_mc;
			
			_photoOutlineTop = _photoOutline.y;
			_photoOutlineBottom = _photoOutline.y + _photoOutline.height;
			_photoOutlineLeft = _photoOutline.x;
			_photoOutlineRight = _photoOutline.x + _photoOutline.width;

			_photo = _instance.photo;
			
			_photoHolder = _instance.photo.photoHolder;
			
			_toolTip = ToolTip.getInstance();		
			_instance.addChild(_toolTip);
						
			_backButton = _instance.backButton_btn;
			_nextButton = _instance.nextButton_btn;
			
			update();
		}
		
		protected function loadLogo():void
		{
			// Override this method
		}
		
		protected function onLogoContentLoaderInfoCompleteHandler(event:Event):void
		{
			// Override this method
		}			
		
		protected function configureGraphics():void
		{
			// Override this method
		}
		
		protected function enableButton(argDisplayObject:SimpleButton, argEnabled:Boolean):void
		{
			argDisplayObject.enabled = argEnabled;
			argDisplayObject.mouseEnabled = argEnabled
			
			var myColor:Color  = new Color();
			
			if (argEnabled)
			{ 
				myColor.setTint(0xFFFFFF, 0);
				argDisplayObject.transform.colorTransform = myColor;
			} else {
				myColor.setTint(0xFFFFFF, .6);
				argDisplayObject.transform.colorTransform = myColor;
			}
		}
		
		protected function populateSelectedProductInformationFields():void
		{
			// Override this method
		}
		
		protected function scaleTextToFitInTextField(textField:TextField, maximumTextFormatSize:Number, minimumTextFormatSize:Number):void
		{  
			var textFormat:TextFormat = textField.getTextFormat();
			
			textFormat.size = (textField.width > textField.height ) ? textField.width : textField.height;
			
			if (textFormat.size > maximumTextFormatSize)
			{
				textFormat.size = maximumTextFormatSize;
			}
			
			if (textFormat.size < minimumTextFormatSize)
			{
				textFormat.size = minimumTextFormatSize;
			}
			
			textField.setTextFormat(textFormat);
			
			while (textField.textWidth > textField.width - 4 || textField.textHeight > textField.height - 6) 
			{    
				textFormat.size = int(textFormat.size) - 1;    
				textField.setTextFormat(textFormat);  
			}
		}

		protected function loadPhoto():void
		{
			var myBitmapDataObject:BitmapData = model.sourceBitmapPositionedBitmapData;
			
			_bitmap = new Bitmap(myBitmapDataObject);
			_bitmap.smoothing = true;
			
			while (_photoHolder.numChildren > 0)
			{
				_photoHolder.removeChildAt(0);
			}
			
			_photoHolder.addChild(_bitmap);
			
			// Technique to allow loaded bitmap to scale relative to its center point
			
			_photoHolderContentOffsetX = -_bitmap.width/2;
			_photoHolderContentOffsetY = -_bitmap.height/2;
			
			_bitmap.x = _photoHolderContentOffsetX;
			_bitmap.y = _photoHolderContentOffsetY;
			
			_photoHolderOffsetX = _photoOutline.width/2;
			_photoHolderOffsetY = _photoOutline.height/2;
			
			_photoHolder.x = _photoHolderOffsetX;
			_photoHolder.y = _photoHolderOffsetY;
		}
		
		protected function addEventListeners():void
		{
			_productHolder.addEventListener(MouseEvent.MOUSE_DOWN, onProductHolderMouseDownHandler);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
			
			_backButton.addEventListener(MouseEvent.CLICK, onBackButtonClickHandler);
			_nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClickHandler);	
			
			model.addEventListener(TransitionEvent.TRANSITION_IN_CUSTOMIZE_PRODUCT_VIEW, transitionIn);
			model.addEventListener(TransitionEvent.TRANSITION_OUT_CUSTOMIZE_PRODUCT_VIEW, transitionOut);

			model.addEventListener(BitmapEvent.STORE_FINAL_RESULT_BITMAP_IN_MODEL_COMPLETE, onStoreFinalResultBitmapInModelCompleteHandler);
			model.addEventListener(BitmapEvent.SAVE_FINAL_RESULT_BITMAP_ON_SERVER_COMPLETED, onSaveFinalResultBitmapOnServerCompleteHandler);		
		}
		
		protected function loadProduct():void
		{
			// Subclass this method
			
			positionProduct();
		}
		
		protected function positionProduct():void
		{
			// Override this method
		}
		
		protected function resetProductHolderPosition():void
		{
			_productHolder.x = _photoHolder.x;
			_productHolder.y = _photoHolder.y;
			_productHolder.scaleX = _photoHolder.scaleX;
			_productHolder.scaleY = _photoHolder.scaleY;
			_productHolder.rotation = _photoHolder.rotation;
			
			controller.initializeUserSpecifiedProductHolderParameters();
			
			controller.setIsFinalResultBitmapStoredInModel(false);
		}
				
		protected function storeFinalResultBitmapInModel():void
		{			
			// Subclass this method
		}
		
		protected function onStoreFinalResultBitmapInModelCompleteHandler(event:BitmapEvent):void
		{
			// Subclass this method

			controller.track(PAGE_NAME, "0", TrackingActions.SAVE_PHOTO_TO_SERVER, "", model.user.email);

			controller.saveFinalResultBitmapOnServer();
		}
		
		protected function onSaveFinalResultBitmapOnServerCompleteHandler(event:BitmapEvent):void
		{
			// Subclass this method			
			switch (_lastButtonClicked)
			{
				case "postToFacebookButton":				
					controller.track(PAGE_NAME, "0", TrackingActions.POST_TO_FACEBOOK, "", model.user.email);
					model.addEventListener(BitmapEvent.SAVE_FACEBOOK_BITMAP_ON_SERVER_COMPLETED, onSaveFacebookBitmapOnServerCompleteHandler);
					controller.saveFacebookBitmapOnServer();
					_lastButtonClicked = "";
					break;
				case "shareViaEmailButton":
					controller.track(PAGE_NAME, "0", TrackingActions.SELECT_EMAIL_BUTTON, "", model.user.email);					
					controller.onShareViaEmailButtonClick();
					_lastButtonClicked = "";
					break;
				case "saveToDesktopButton":
					controller.track(PAGE_NAME, "0", TrackingActions.SAVE_TO_DESKTOP, "", model.user.email);					
					controller.onSaveToDesktopButtonClick();
					_lastButtonClicked = "";
					break;
				default:
					controller.track(PAGE_NAME, "0", TrackingActions.NEXT, "", model.user.email);					
					showShareProductView();
					_lastButtonClicked = "";
					break;
			}
		}
		
		protected function onSaveFacebookBitmapOnServerCompleteHandler(event:BitmapEvent):void
		{
			model.removeEventListener(BitmapEvent.SAVE_FACEBOOK_BITMAP_ON_SERVER_COMPLETED, onSaveFacebookBitmapOnServerCompleteHandler);

			controller.setIsShowOkButtonOnMessageBoxView(true);
			controller.showMessageBoxView("Click 'Ok' to post photo on Facebook");
		}
		
		protected function showShareProductView():void
		{
			// Subclass this method
			
			controller.showShareProductView();
		}		
		
		protected function onProductHolderMouseDownHandler(event:MouseEvent):void
		{
			controller.storeRepositionedProductHolderParameters(_photoHolder.x, _photoHolder.y, _photoHolder.scaleX, _photoHolder.scaleY, _photoHolder.rotation);

			_productHolder.startDrag();
		}
		
		protected function onBackButtonClickHandler(event:Event):void
		{
			controller.track(PAGE_NAME, "0", TrackingActions.BACK, "", model.user.email);

			controller.onBackButtonClick();
		}
		
		protected function onLogoClickHandler(event:MouseEvent):void
		{
			var logoLinkURL:String;
			logoLinkURL = _config.company_info.logo_link_url;
			
			var urlRequest:URLRequest = new URLRequest(logoLinkURL);
			
			if (urlRequest.url.indexOf("www.") == 0)
			{
				urlRequest.url = "http://" + urlRequest.url;
			}
			
			logoLinkURL = urlRequest.url;
			
			_popup.getMyURL(logoLinkURL);
			
			controller.track(PAGE_NAME, "0", TrackingActions.SELECT_ADVERTISER_LOGO, "", model.user.email);
			
			controller.track(PAGE_NAME, "0", TrackingActions.EXIT_URL, logoLinkURL, model.user.email);	
		}
		
		protected function onPostToFacebookButtonClickHandler(event:MouseEvent):void
		{
			_lastButtonClicked = "postToFacebookButton";
			
			// Subclass this method
			
			// Reset product position, scale, and rotation for the demo model based on a flag in config.xml to assure you can or can't publish photos of the demo model with wonky product placement
			if (model.isUseDemoModel && _config.banner_info.allow_user_to_share_modified_product_on_demo_model == "false")
			{
				loadProduct();
			}
			
			// Override alphaTimer if one was in effect
			_productHolder.alpha = 1;
			
			storeFinalResultBitmapInModel();
		}
		
		protected function onShareViaEmailButtonClickHandler(event:MouseEvent):void
		{
			_lastButtonClicked = "shareViaEmailButton";
			
			// Subclass this method
			
			// Reset product position, scale, and rotation for the demo model based on a flag in config.xml to assure you can or can't publish photos of the demo model with wonky product placement
			if (model.isUseDemoModel && _config.banner_info.allow_user_to_share_modified_product_on_demo_model == "false")
			{
				loadProduct();
			}
			
			// Override alphaTimer if one was in effect
			_productHolder.alpha = 1;
			
			storeFinalResultBitmapInModel();
		}
		
		protected function onSaveToDesktopButtonClickHandler(event:MouseEvent):void
		{
			_lastButtonClicked = "saveToDesktopButton";
			
			// Subclass this method
			
			// Reset product position, scale, and rotation for the demo model based on a flag in config.xml to assure you can or can't publish photos of the demo model with wonky product placement
			if (model.isUseDemoModel && _config.banner_info.allow_user_to_share_modified_product_on_demo_model == "false")
			{
				loadProduct();
			}
			
			// Override alphaTimer if one was in effect
			_productHolder.alpha = 1;
			
			storeFinalResultBitmapInModel();
		}
		
		protected function onNextButtonClickHandler(event:Event):void
		{
			// Subclass this method
			
			// Reset product position, scale, and rotation for the demo model based on a flag in config.xml to assure you can or can't publish photos of the demo model with wonky product placement
			if (model.isUseDemoModel && _config.banner_info.allow_user_to_share_modified_product_on_demo_model == "false")
			{
				loadProduct();
			}
			
			// Override alphaTimer if one was in effect
			_productHolder.alpha = 1;
			
			if (!model.isFinalResultBitmapStoredInModel)
			{
				storeFinalResultBitmapInModel();
			} else {
				controller.track(PAGE_NAME, "0", TrackingActions.NEXT, "", model.user.email);
				controller.onNextButtonClick();
			}
		}
		
		// ------------------------------------------------------------------------------------------------------------------------------------		
		
		protected function scaleDisplayObject(argTarget:DisplayObject, argScaleXIncrement:Number = 0, argScaleYIncrement:Number = 0):void
		{			
			argTarget.scaleX += argScaleXIncrement;			
			argTarget.scaleY += argScaleYIncrement;
			
			if (argTarget.scaleX > CustomizeProductView.MAXIMUM_SCALE)
			{
				argTarget.scaleX = CustomizeProductView.MAXIMUM_SCALE
			}
			
			if (argTarget.scaleY > CustomizeProductView.MAXIMUM_SCALE)
			{
				argTarget.scaleY =CustomizeProductView. MAXIMUM_SCALE
			}
			
			if (argTarget.scaleX < CustomizeProductView.MINIMUM_SCALE)
			{
				argTarget.scaleX = CustomizeProductView.MINIMUM_SCALE
			}
			
			if (argTarget.scaleY < CustomizeProductView.MINIMUM_SCALE)
			{
				argTarget.scaleY = CustomizeProductView.MINIMUM_SCALE
			}
		}
		
		protected function rotateDisplayObject(argTarget:DisplayObject, argRotationIncrement:Number = 0):void
		{
			argTarget.rotation += argRotationIncrement;
		}
		
		protected function onStageMouseUpHandler(event:MouseEvent = null):void
		{
			_productHolder.stopDrag();
		}
		
		protected function onCloseButtonClickHandler(event:MouseEvent):void
		{
			controller.onCloseButtonClick(event);
		}

		protected function onProductTransformItemSelectMouseDownHandler(event:TransformEvent):void
		{
			_productHolder.startDrag();

			controller.setIsFinalResultBitmapStoredInModel(false);
		}
		
		protected function onProductTransformItemSelectMouseUpHandler(event:TransformEvent = null):void
		{
			_productHolder.stopDrag();
		}
		
		protected function onProductTransformItemTransformHandler(event:TransformEvent):void
		{
			_productHolder.stopDrag();
			
			controller.setIsFinalResultBitmapStoredInModel(false);
		}
		
		protected function onProductTransformItemFinishInteractiveMoveHandler(event:TransformEvent):void
		{
			// Overrride function
		}
		
		protected function onProductTransformItemFinishInteractiveScaleHandler(event:TransformEvent):void
		{
			// Overrride function
		}
		
		protected function onProductTransformItemFinishInteractiveRotateHandler(event:TransformEvent):void
		{
			// Overrride function
		}
		
		protected function showToolTip(argToolTipText:String):void
		{
			if (_config.banner_info.is_show_tooltips == "true")
			{
				_toolTip.show(argToolTipText);
			}
		}
		
		protected function hideToolTip():void
		{
			_toolTip.hide();
		}
		
		public function get lastButtonClicked():String
		{
			return _lastButtonClicked;
		}
		
		public function set lastButtonClicked(value:String):void
		{
			_lastButtonClicked = value;
		}

		private function bringObjectToTop(argObject:*):void
		{
			container.setChildIndex(argObject, container.numChildren-1);
		}
		
		protected function resetTransition():void
		{
			// Subclass this method
		}
		
		protected function onIoErrorHandler(event:IOErrorEvent):void {
			trace("Abstract Customize Product View ioErrorHandler: " + event);
		}
		
		protected function transitionIn(event:Event = null):void
		{
			// Subclass this method
			
			update();
			bringObjectToTop(_instance);
			model.addEventListener (Model.MODEL_CHANGE, update);
			
			controller.track(PAGE_NAME, "0", TrackingActions.VIEWED_PAGE, "", model.user.email);
		}
		
		protected function transitionOut(event:Event = null):void
		{
			// Subclass this method
			
			model.removeEventListener (Model.MODEL_CHANGE, update);
		}
		
		protected function onTransitionInCompleteHandler():void
		{
			// Subclass this method
		}

		override public function update (event : Event = null)  :  void
		{		
			// Subclass this method
			
			trace("AbstractCustomizeProductView Updated");

			loadPhoto();
			loadProduct();
			populateSelectedProductInformationFields();	
			
			super.update(event);
		}

		public function get popup():PopUp
		{
			return _popup;
		}
		
	}
	
}