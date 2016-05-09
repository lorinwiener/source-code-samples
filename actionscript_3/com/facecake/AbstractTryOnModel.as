package com.facecake.tryon.abstract.model
{
	
	import com.adobe.images.JPGEncoder;
	import com.adobe.serialization.json.JSON;
	import com.facecake.facebook.graph.Facebook;
	import com.facecake.facebook.graph.FacebookOAuthGraph;
	import com.facecake.facebook.graph.events.FacebookOAuthGraphEvent;
	import com.facecake.metrics.Tracking;
	import com.facecake.tryon.abstract.events.AbstractValidateEmailAddressExistsCompleteEvent;
	import com.facecake.tryon.abstract.main.AbstractMain;
	import com.facecake.tryon.events.BitmapEvent;
	import com.facecake.tryon.events.FacebookEvent;
	import com.facecake.tryon.events.TransitionEvent;
	import com.facecake.tryon.model.TryOnModel;
	import com.facecake.tryon.mvc.Model;
	import com.facecake.tryon.user.User;
	import com.facecake.tryon.vo.ColorVO;
	import com.facecake.tryon.vo.FacebookAlbumVO;
	import com.facecake.tryon.vo.ProductVO;
	import com.facecake.utils.AMFPHP;
	import com.facecake.utils.GenerateGUID;
	import com.facecake.utils.HTTPCookies;
	import com.facecake.utils.LoadPhoto;
	import com.facecake.utils.PopUp;
	import com.greensock.events.TransformEvent;
	import com.greensock.transform.TransformItem;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * Abstract MVC Model to store Try-On data
	 */
	public class AbstractTryOnModel extends Model
	{		
		
		protected static const WINDOW_OPEN_FUNCTION:String = "window.open";
		
		protected var _baseURL:String;
		protected var _config:XML;
		protected var _amfPhpFilePath:String;
		protected var _sessionID:int;
		protected var _templateID:String;
		protected var _facecakeAppID:String;
		protected var _relativeTemplatesDirectory:String;
		protected var _usersDirectoryName:String;
		protected var _userDirectoryURL:String;
		protected var _applicationImagesDirectoryURL:String;
		protected var _facebook:Facebook;
		protected var _facebookAppID:String;
		protected var _facebookScope:String;
		protected var _main:Object;
		protected var _localSharedObject:SharedObject;
		protected var _isRegistrationRequired:Boolean;
		protected var _user:User;
		protected var _isUseDemoModel:Boolean = false;
		protected var _isUploadFromWebcam:Boolean = false;
		protected var _isUploadFromComputer:Boolean = false;
		protected var _isUploadFromFacebook:Boolean = false;
		protected var _finalResultBitmapFilename:String;
		protected var _emailBitmapFilename:String;
		protected var _productArray:Array;
		protected var _recommendedProductViewIdsArray:Array;
		protected var _sourceBitmap:Bitmap;
		protected var _sourceBitmapPositionedBitmapData:BitmapData;
		protected var _sourceBitmapPositionedBitmapDataTemp:BitmapData;
		protected var _productBitmap:Bitmap;
		protected var _finalResultBitmap:Bitmap;
		protected var _featuresObject:Object;
		protected var _encoder:JPGEncoder;
		protected var _uploadedPhotoByteArray:ByteArray;
		protected var _finalResultByteArray:ByteArray;
		protected var _isUserInteractedWithBanner:Boolean = false;
		protected var _hasTryOnViewBeenViewed:Boolean = false;
		protected var _hasSelectPhotoSourceViewBeenViewed:Boolean = false;
		
		protected var _userSpecifiedPhotoHolderXPos:Number;
		protected var _userSpecifiedPhotoHolderYPos:Number;
		protected var _userSpecifiedPhotoHolderScaleX:Number;
		protected var _userSpecifiedPhotoHolderScaleY:Number;
		protected var _userSpecifiedPhotoHolderRotation:Number;
		
		protected var _userSpecifiedProductHolderXPos:Number;
		protected var _userSpecifiedProductHolderYPos:Number;
		protected var _userSpecifiedProductHolderScaleX:Number;
		protected var _userSpecifiedProductHolderScaleY:Number;
		protected var _userSpecifiedProductHolderRotation:Number;
		
		protected var _userSpecifiedPhotoHolderXPosTemp:Number;
		protected var _userSpecifiedPhotoHolderYPosTemp:Number;
		protected var _userSpecifiedPhotoHolderScaleXTemp:Number;
		protected var _userSpecifiedPhotoHolderScaleYTemp:Number;
		protected var _userSpecifiedPhotoHolderRotationTemp:Number;	

		protected var _userSpecifiedProductHolderXPosTemp:Number;
		protected var _userSpecifiedProductHolderYPosTemp:Number;
		protected var _userSpecifiedProductHolderScaleXTemp:Number;
		protected var _userSpecifiedProductHolderScaleYTemp:Number;
		protected var _userSpecifiedProductHolderRotationTemp:Number;		
		
		protected var _selectedProductIndex:int;
		protected var _selectedColorIndex:int;
		protected var _processingImageViewMessage:String;
		protected var _isFinalResultBitmapStoredInModel:Boolean;
		
		protected var _emailSenderName:String;
		protected var _emailSenderEmailAddress:String;
		protected var _emailRecipientName:String;
		protected var _emailRecipientEmailAddress:String;
		protected var _emailBody:String;
		protected var _defaultEmailMessage:String;
		protected var _isUserOptIn:Boolean = true;

		protected var _facebookAlbumsArray:Array;
		protected var _selectedFacebookAlbumPhotoURLArray:Array;
		protected var _selectedFacebookPhotoURL:String;
		protected var _loggedIntoFacebook:Boolean;
		
		protected var _messageBoxViewMessage:String;
		protected var _tracking:Tracking;
		
		protected var _productURL:String;
		
		protected var _photoMaskWidth:Number;
		protected var _photoMaskHeight:Number;
		
		protected var _finalResultBitmapWidth:Number;
		protected var _finalResultBitmapHeight:Number;	
		
		protected var _facebookPhotoFilename:String;
		
		protected var _lastItemClickedOn:String;
		protected var _lastItemClickedOnProductViewId:String;
		
		protected var _objectsDetectedJSONString:String;
		
		protected var _objectRecognitionBitmapData:BitmapData;
		protected var _objectRecognitionBitmap:Bitmap;
		
		protected var _objectRecognitionPhotoByteArray:ByteArray;
		
		protected var _objectRecognitionBitmapFilename:String;
		
		protected var _popup:PopUp;
		
		public var _amf:AMFPHP;
		public var _uploadedBitmapFilename:String;
		public var _relativeUsersDirectory:String;
		public var _isRegistered:Boolean = false;
		public var _isViewedPhotoTakingInstructions:Boolean = false;
		
		private var _isShowOkButtonOnMessageBoxView:Boolean = false;
		
		
		public function AbstractTryOnModel (argPhotoMaskWidth:Number, argPhotoMaskHeight:Number, argFinalResultBitmapWidth:Number, argFinalResultBitmapHeight:Number)
		{		
			_photoMaskWidth = argPhotoMaskWidth;
			_photoMaskHeight = argPhotoMaskHeight;
			
			_finalResultBitmapWidth = argFinalResultBitmapWidth;
			_finalResultBitmapHeight = argFinalResultBitmapHeight;
			
			initialize();
			
			trace("AbstractTryOnModel Instantiated");
		}
		
		protected function initialize () : void
		{			
			// Set security policies for Facebook photo album browsing
			Security.loadPolicyFile("http://api.facebook.com/crossdomain.xml");	
			Security.loadPolicyFile("http://graph.facebook.com/crossdomain.xml");
			Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
			
			Security.loadPolicyFile("https://sphotos.xx.fbcdn.net/crossdomain.xml");
			Security.loadPolicyFile("https://sphotos-a.xx.fbcdn.net/crossdomain.xml");
			Security.loadPolicyFile("https://sphotos-b.xx.fbcdn.net/crossdomain.xml");
			Security.loadPolicyFile("https://sphotos-c.xx.fbcdn.net/crossdomain.xml");
			Security.loadPolicyFile("https://sphotos-d.xx.fbcdn.net/crossdomain.xml")
			
			Security.loadPolicyFile("http://cache.facecake.com/crossdomain.xml");
			Security.loadPolicyFile("http://media.facecake.com/crossdomain.xml");
			
			Security.allowDomain(ExternalInterface.call('window.location.href.toString'));
			Security.allowInsecureDomain(ExternalInterface.call('window.location.href.toString'));

			_amf = AMFPHP.getInstance();
			
			_localSharedObject = SharedObject.getLocal("tryOnBanner");
			
			// Delete local shared object for registration testing purposes
			if (CONFIG::CLEAR_LOCAL_SHARED_OBJECT == true)
			{
				_localSharedObject.clear();
				_isRegistered = false;
			}
			
			if (_localSharedObject.data.email)
			{
				_isRegistered = true;
			}
			
			_productArray = new Array();
			_recommendedProductViewIdsArray = new Array();
			_facebookAlbumsArray = new Array();
			_selectedFacebookAlbumPhotoURLArray = new Array();
			_loggedIntoFacebook = false;
			
			objectsDetectedJSONString = "";
			
			initializeProductAndColorSelectedIndices();
			
			_processingImageViewMessage = "";
			_messageBoxViewMessage = "";
			
			initializeUserSpecifiedPhotoHolderParameters();
			initializeUserSpecifiedProductHolderParameters();
			
			_encoder = new JPGEncoder(80);
			
			_uploadedPhotoByteArray = new ByteArray();
			_finalResultByteArray = new ByteArray();
				
			_isFinalResultBitmapStoredInModel = false;
			
			_facebook = Facebook.instance;
			
			_popup = new PopUp();
			
			_tracking = Tracking.getInstance();		
			
			_tracking.addEventListener("Collapse", onCollapseEventHandler);
			
			updateData();
		}
		
		public function initializeProductAndColorSelectedIndices():void
		{
			_selectedProductIndex = 0;
			_selectedColorIndex = 0;
		}
		
		public function populateLocalSharedObject(argEmail:String):void
		{
			_localSharedObject.data.email = argEmail;
		}
		
		public function createProductArray():void
		{
			var productVO:ProductVO;
			var colorVO:ColorVO;
			var productXMLList:XMLList;
			var numberOfProducts:int;
			var colorXMLList:XMLList;
			var numberOfColors:int;
			
			productXMLList = _config..product;
			numberOfProducts = productXMLList.length();
			
			_productArray = [];
			
			for (var i:int=0; i<numberOfProducts; i++)
			{
				productVO = new ProductVO();
				
				productVO.productManufacturer = productXMLList[i].manufacturer;
				productVO.productModel = productXMLList[i].model;
				productVO.productDescription = productXMLList[i].description;
				productVO.thumbnailFilename = productXMLList[i].thumbnail_filename;
				
				colorXMLList = productXMLList[i]..color;
				numberOfColors = colorXMLList.length();
				
				for (var j:int=0; j<numberOfColors; j++)
				{
					colorVO = new ColorVO();
					
					colorVO.colorDescription = colorXMLList[j].color_description;
					colorVO.colorHexCode = colorXMLList[j].color_hex_code;
					colorVO.price = colorXMLList[j].price;
					colorVO.productFilename = colorXMLList[j].product_filename;
					colorVO.productURL = colorXMLList[j].product_url;
					colorVO.productViewId = colorXMLList[j].product_view_id;
					productVO.addColor(colorVO);
				}
				
				_productArray.push(productVO);
			}
			
		}
		
		// Select photo source methods
		
		public function uploadFromWebcam():void
		{
			// Subclass this method
			
			_isUploadFromWebcam = true;
			_isUploadFromComputer = false;
			_isUploadFromFacebook = false;
			_isUploadFromFacebook = false;
			_isUseDemoModel = false;
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Click_To_Upload_Your_Photo_From_Webcam", true);
			}
		}
		
		public function uploadFromComputer():void
		{
			// Subclass this method

			_isUploadFromWebcam = false;
			_isUploadFromComputer = true;
			_isUploadFromFacebook = false;
			_isUseDemoModel = false;
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Click_To_Upload_Your_Photo", true);
			}
		}

		public function browseLocalPhotos():void
		{
			var loadPhoto:LoadPhoto;
			
			_isUseDemoModel = false;
			
			loadPhoto = new LoadPhoto();
			loadPhoto.addEventListener(Event.COMPLETE, onLoadPhotoCompleteHandler);
			loadPhoto.browse();
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Upload", true);
			}
		}
		
		protected function onIoErrorHandler(event:IOErrorEvent):void {
			trace("Abstract TryOn Model ioErrorHandler: " + event);
		}
		
		protected function onLoadPhotoCompleteHandler(event:Event):void
		{
			var loader:Loader = event.target.loader as Loader;
			var bitmap:Bitmap = new Bitmap(Bitmap(loader.content).bitmapData, "auto", true);
			
			bitmap.smoothing = true;
			
			if (bitmap.width > 1000) {
				var ratio:Number = 1000 / bitmap.width;
				bitmap.width *= ratio;
				bitmap.height *= ratio;
			}
			
			// Scale uploaded bitmap to fit in photo outline
			
			var scale:Number;
			
			if (bitmap.height > bitmap.width) {
				scale = TryOnModel.PHOTO_MASK_HEIGHT / bitmap.height;
				bitmap.height = TryOnModel.PHOTO_MASK_HEIGHT;
				bitmap.width *= scale;
			} else {
				scale = TryOnModel.PHOTO_MASK_WIDTH / bitmap.width;
				bitmap.width = TryOnModel.PHOTO_MASK_WIDTH;
				bitmap.height *= scale;
			}
			
			_sourceBitmap = bitmap;
			
			initializeUserSpecifiedPhotoHolderParameters();
			initializeUserSpecifiedProductHolderParameters();

			_isFinalResultBitmapStoredInModel = false;
			
			hideTryOnView();
			hideSelectPhotoSourceView();
			hidePhotoTakingInstructionsView();
			hideSelectFacebookPhotoView();
			
			// Skip ahead to Customize Product View if using demo model
			if (_isUseDemoModel == true)
			{
				_sourceBitmapPositionedBitmapData = _sourceBitmap.bitmapData;

				showCustomizeProductView();
			} else {
				hidePhotoTakingInstructionsView();
				showPositionPhotoView();
			}
		}
		
		public function browseFacebookAlbums():void
		{
			_isUploadFromWebcam = false;
			_isUploadFromComputer = false;
			_isUploadFromFacebook = true;
			_isUseDemoModel = false;
			
			_isUseDemoModel = false;
			
			if (_isRegistered)
			{
				if (_loggedIntoFacebook)
				{
					if (_isViewedPhotoTakingInstructions)
					{
						var resultObject:Object = new Object();
						resultObject.status = "connected";
						onFacebookStatusChangeCompleteHandler(resultObject);
					} else {
						hideTryOnView();
						hideSelectPhotoSourceView();
						showPhotoTakingInstructionsView();
					}
				} else {
					initializeFacebookObject();
					connectToFacebook();
				}
			} else {
				showRegisterView();
			}
			
		}
		
		public function initializeFacebookObject():void
		{
			var randomLocalConnectionObjectName:String;
			
			_isUseDemoModel = false;
			
			randomLocalConnectionObjectName = Main.LOCAL_CONNECTION_OBJECT_NAME_PREFIX  + "_" + String(Math.floor(Math.random()*1000000));
			
			_facebook.clientID = _facebookAppID;			
			_facebook.randomLocalConnectionObjectName = randomLocalConnectionObjectName
			
			_facebook.redirectURI = "http://" + main.CDNDomain + "/" + main.environment + "/" + main.applicationNameAcronym + "/" + main.CDNTemplateDirectoryName + "/facebookCallback.html?connectionName=" + randomLocalConnectionObjectName;
			
			_facebook.scope = _facebookScope;
			_facebook.useSecuredPath = true;
			
			_facebook.addEventListener(FacebookOAuthGraphEvent.AUTHORIZED, onFacebookAuthorizedEventHandler);
			_facebook.addEventListener(FacebookOAuthGraphEvent.UNAUTHORIZED, onFacebookUnauthorizedEventHandler);
			_facebook.addEventListener(FacebookOAuthGraphEvent.ERROR, onFacebookErrorEventHandler);			
		}
		
		protected function connectToFacebook():void
		{			
			showProcessingImageView("Please Wait");
			
			if (main.isSWFRunningLocally)
			{
				var parameters = _facebook.hackToken(new Object(), Main.FACEBOOK_ACCESS_TOKEN);
				_facebook.autoConnect(parameters);
			} else {
				_facebook.connect();
			} 
		}
		
		protected function onFacebookAuthorizedEventHandler(event:FacebookOAuthGraphEvent):void
		{
			hideProcessingImageView();
			
			if (event.type == FacebookOAuthGraphEvent.AUTHORIZED)
			{
				_loggedIntoFacebook = true;	
				
				if (_isViewedPhotoTakingInstructions)
				{
					showSelectFacebookPhotoView();
				} else {
					hideTryOnView();
					hideSelectPhotoSourceView();
					showPhotoTakingInstructionsView();
				}
				
			} else {				
				_loggedIntoFacebook = false;
			}
		}
		
		protected function onFacebookUnauthorizedEventHandler(event:FacebookOAuthGraphEvent):void
		{				
			_loggedIntoFacebook = false;
			
			hideProcessingImageView();
			
			connectToFacebook();
		}
		
		protected function onFacebookErrorEventHandler(event:FacebookOAuthGraphEvent):void
		{				
			_loggedIntoFacebook = false;
			
			hideProcessingImageView();
			
			connectToFacebook();
		}
		
		protected function onFacebookStatusChangeCompleteHandler(result:Object):void
		{
			if (result && result.status)
			{
				switch (result.status)
				{
					case "connected":
						trace("Facebook account connected");
						_loggedIntoFacebook = true;							
						if (_isViewedPhotoTakingInstructions)
						{
							showSelectFacebookPhotoView();
						} else {
							hideTryOnView();
							hideSelectPhotoSourceView();
							showPhotoTakingInstructionsView();
						}
						break;
					case "notConnected":
						trace("Facebook account NOT connected");
						break;
					case "unknown":
						trace("Facebook account connection state unknown");
						break;
				}
			}
		}
		
		public function loadFacebookAlbums():void
		{		
			_facebook.addEventListener(FacebookOAuthGraphEvent.DATA, onLoadFacebookAlbumsCompleteHandler);
			_facebook.call("me/albums");
			
			showProcessingImageView("Please Wait");
		}

		protected function onLoadFacebookAlbumsCompleteHandler(event:FacebookOAuthGraphEvent):void
		{
			_facebook.removeEventListener(FacebookOAuthGraphEvent.DATA, onLoadFacebookAlbumsCompleteHandler);
			
			hideProcessingImageView();
			
			if (event.data)
			{
				createFacebookAlbumsArray(event);
			}			
		}
		
		protected function createFacebookAlbumsArray(event:FacebookOAuthGraphEvent):void
		{			
			var facebookAlbumVO:FacebookAlbumVO;
			
			_facebookAlbumsArray = [];
			
			for (var i:int = 0; i < event.data.data.length; i++)
			{
				facebookAlbumVO = new FacebookAlbumVO();
				facebookAlbumVO.albumID = event.data.data[i].id;
				facebookAlbumVO.albumName = event.data.data[i].name;
				_facebookAlbumsArray.push(facebookAlbumVO);
			}
			
			dispatchEvent(new FacebookEvent(FacebookEvent.FACEBOOK_ALBUMS_ARRAY_UPDATED));
		}		
		
		public function loadSelectedFacebookAlbum(argAlbumID:String):void
		{
			var id:String;
			
			id = argAlbumID;
			
			showProcessingImageView("Please Wait");
			
			_facebook.addEventListener(FacebookOAuthGraphEvent.DATA, onLoadSelectedFacebookAlbumPhotosCompleteHandler);
			_facebook.call("/" + id + "/photos");
		}
		
		protected function onLoadSelectedFacebookAlbumPhotosCompleteHandler(facebookAlbumPhotosObject:Object):void
		{			
			_facebook.removeEventListener(FacebookOAuthGraphEvent.DATA, onLoadSelectedFacebookAlbumPhotosCompleteHandler);
			
			hideProcessingImageView();
			
			// Clear existing photos from prior browse
			_selectedFacebookAlbumPhotoURLArray = [];
			
			for (var i:int = 0; i < facebookAlbumPhotosObject.data.data.length; i++)
			{
				_selectedFacebookAlbumPhotoURLArray.push(facebookAlbumPhotosObject.data.data[i].source);
			}
			
			dispatchEvent(new FacebookEvent(FacebookEvent.SELECTED_FACEBOOK_ALBUM_PHOTO_URL_ARRAY_UPDATED));
		}
		
		public function loadProduct(argProductIndex:int = 0, argColorIndex:int = 0):void
		{
			var loader:Loader;
			var url:String;
			var urlRequest:URLRequest;
			
			_selectedProductIndex = argProductIndex;

			_selectedColorIndex = argColorIndex;
	
			url = _productArray[_selectedProductIndex].colorArray[_selectedColorIndex].productFilename;
	
			if (url.length > 0)
			{	
				if (_productArray[_selectedProductIndex].colorArray[_selectedColorIndex].productBitmap != null)
				{
					
					_productBitmap = _productArray[_selectedProductIndex].colorArray[_selectedColorIndex].productBitmap;

					_productBitmap.smoothing = true;
					
					updateData();
					
				} else {
					
					loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadProductCompleteHandler);
					
					urlRequest = new URLRequest(url);
					
					if (urlRequest.url.indexOf("http://") == 0 || urlRequest.url.indexOf("www.") == 0)
					{
						urlRequest.url = _amfPhpFilePath + "loadImageFromExternalDomain.php?file=" + urlRequest.url;
					}

					loader.load(urlRequest);
					
					//super.showProcessingImageView("Please wait...");
					
				}
				
			} else {	
				
				_productBitmap = new Bitmap(new BitmapData(1, 1, true), "auto", true);
				
				updateData();
			}
			
			generateDefaultEmailMessage();
		}
		
		protected function onLoadProductCompleteHandler(event:Event):void
		{
			var loader:Loader = event.target.loader as Loader;

			var bitmap:Bitmap = new Bitmap(Bitmap(loader.content).bitmapData, "auto", true);
			
			event.currentTarget.removeEventListener(Event.COMPLETE, onLoadProductCompleteHandler);
			
			_productBitmap = bitmap;
			_productBitmap.smoothing = true;
			
			_productArray[_selectedProductIndex].colorArray[_selectedColorIndex].productBitmap = _productBitmap;
				
			updateData();
		}
		
		protected function generateDefaultEmailMessage():void
		{
			_productURL = _productArray[_selectedProductIndex].colorArray[_selectedColorIndex].productURL.toString();
			
			if (_productURL == "")
			{
				_productURL = _config.company_info.logo_link_url;
			}			
			
			_defaultEmailMessage = _config.send_email_view.default_email_message;
		}
		
		public function useDemoModel():void
		{
			_isUseDemoModel = true;
			
			loadDemoModel();
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Try-On_Our_Demo_Model", true);
			}
		}
		
		public function onFooterClickHandler(urlRequest:URLRequest):void
		{
			if (!main.isSWFRunningLocally)
			{
				if (_config.banner_info.has_doubleclick_tracking == "true")
				{
					main.enabler.exit("FaceCake_URL", urlRequest.url);
				} else if (_config.banner_info.has_eyeblaster_tracking == "true") {
					EB.Clickthrough("Pri_Facecake_URL_Click_Clickthrough_CLICK");
					openURLInBrowserWindow(urlRequest.url, "_blank");
				} else {
					openURLInBrowserWindow(urlRequest.url, "_blank");
				}
			} else {
				openURLInBrowserWindow(urlRequest.url, "_blank");
			}
		}
		
		public function onLogoClickHandler(urlRequest:URLRequest):void
		{
			if (!main.isSWFRunningLocally)
			{
				if (_config.banner_info.has_doubleclick_tracking == "true")
				{
					main.enabler.exit("Logo_URL", urlRequest.url);
				} else if (_config.banner_info.has_eyeblaster_tracking == "true") {
					EB.Clickthrough("Pri_Logo_URL_Click_Clickthrough_CLICK");
					openURLInBrowserWindow(urlRequest.url, "_blank");
				} else {
					openURLInBrowserWindow(urlRequest.url, "_blank");
				}
			} else {
				openURLInBrowserWindow(urlRequest.url, "_blank");
			}
		}

		public function openProductPageURL(urlRequest:URLRequest):void
		{
			if (!main.isSWFRunningLocally)
			{
				if (_config.banner_info.has_doubleclick_tracking == "true")
				{
					main.enabler.exit("Product_URL", urlRequest.url);
				} else if (_config.banner_info.has_eyeblaster_tracking == "true") {
					EB.Clickthrough("Pri_Product_URL_Click_Clickthrough_CLICK");
					openURLInBrowserWindow(urlRequest.url, "_blank");
				} else {
					openURLInBrowserWindow(urlRequest.url, "_blank");
				}
			} else {
				openURLInBrowserWindow(urlRequest.url, "_blank");
			}
		}
		
		
		protected function loadDemoModel():void
		{
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = _config.select_photo_source_view.demo_model_filename.toString();
			
			if (urlRequest.url.indexOf("http://") == 0 || urlRequest.url.indexOf("www.") == 0)
			{
				urlRequest.url = amfPhpFilePath + "loadImageFromExternalDomain.php?file=" + urlRequest.url;
			}

			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadPhotoCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorHandler);
			loader.load(urlRequest);
		}
		
		public function loadFacebookPhoto():void
		{
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = _selectedFacebookPhotoURL;
			
			var context:LoaderContext;
			var loader:Loader = new Loader();
			
			context = new LoaderContext();
			context.checkPolicyFile = true;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadPhotoCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorHandler);
			
			loader.load(urlRequest,context);
		}
		
		public function initializeUserSpecifiedPhotoHolderParameters():void
		{
			_userSpecifiedPhotoHolderXPos = NaN;
			_userSpecifiedPhotoHolderYPos = NaN;
			_userSpecifiedPhotoHolderScaleX = NaN;
			_userSpecifiedPhotoHolderScaleY = NaN;
			_userSpecifiedPhotoHolderRotation = NaN;
		}
		
		public function initializeUserSpecifiedProductHolderParameters():void
		{
			_userSpecifiedProductHolderXPos = NaN;
			_userSpecifiedProductHolderYPos = NaN;
			_userSpecifiedProductHolderScaleX = NaN;
			_userSpecifiedProductHolderScaleY = NaN;
			_userSpecifiedProductHolderRotation = NaN;
		}
		
		public function createRegisteredUser(argFirstName:String, argLastName:String, argEmail:String, argGender:String):void
		{
			_user.firstName = argFirstName;
			_user.lastName = argLastName;
			_user.email = argEmail;
			_user.gender = argGender;
			
			var responder:Responder = new Responder(onCreateUserComplete, _amf.onRemoteFault);
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "create_user", responder, _user.firstName, _user.lastName, _user.email, _user.gender, _sessionID, _relativeUsersDirectory);			 
		}
		
		protected function onCreateUserComplete(argUserId:int):void
		{
			_isRegistered = true;
			_user.userId = argUserId;
			
			populateLocalSharedObject(_user.email);
			
			// Set user email on browser cookie
			if (main.isSWFRunningLocally == false)
			{
				HTTPCookies.setCookie('email', _user.email);
			}
			
			hideRegisterView();
			
			if (_isUploadFromWebcam)
			{
				uploadFromWebcam();
			} else if (_isUploadFromComputer) {
				uploadFromComputer();
			} else if (_isUploadFromFacebook) {
				browseFacebookAlbums();
			}			
		}		
		
		public function encodeObjectRecognitionBitmap():void
		{			
			_objectRecognitionPhotoByteArray = _encoder.encode(_objectRecognitionBitmapData);
		}
		
		public function encodeUploadedBitmap():void
		{			
			_uploadedPhotoByteArray = _encoder.encode(_sourceBitmapPositionedBitmapData);
			
			if (_config.banner_info.has_object_recognition == "true")
			{
				saveObjectRecognitionPhoto();
			} else {
				saveUploadedPhoto();
			}
		}
		
		protected function saveObjectRecognitionPhoto():void
		{		
			trace("Saving object recognition photo");
			
			var responder:Responder = new Responder(onSaveObjectRecognitionPhotoComplete, _amf.onRemoteFault);
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "save_jpg", responder, _objectRecognitionPhotoByteArray, "objectRecognitionBitmap", user.userId, _relativeUsersDirectory);
		}
		
		protected function onSaveObjectRecognitionPhotoComplete(argFilename:String):void
		{	
			// Subclass this method
			
			_objectRecognitionBitmapFilename = argFilename;

			detectObjectInPhoto();
		}
		
		protected function detectObjectInPhoto():void
		{
			trace("Detecting objects in photo");
			
			var comparisonObjectsString01:String;
			var comparisonObjectsString02:String;
			
			var responder:Responder = new Responder(onDetectObjectInPhotoComplete, _amf.onRemoteFault);
			
			comparisonObjectsString01 = "..\\..\\img\\" + "comparison_object_corona_extra.jpg";
			comparisonObjectsString02 = "..\\..\\img\\" + "comparison_object_corona_light.jpg";
			
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "detect_object_in_photo", responder, "10", "..\\..\\users\\" + user.userId + "\\" + _objectRecognitionBitmapFilename, comparisonObjectsString01, comparisonObjectsString02);
		}
		
		protected function onDetectObjectInPhotoComplete(data:String):void
		{
			if (data != '{}') {				
				trace("Object(s) detected");
				_objectsDetectedJSONString = data;
				trace("_objectsDetectedJSONString = " + _objectsDetectedJSONString);
				saveUploadedPhoto();
			} else {
				trace("No object(s) detected!");
				saveUploadedPhoto();
			}
		}
		
		protected function saveUploadedPhoto():void
		{		
			trace("Saving uploaded photo");
			
			var responder:Responder = new Responder(onSaveUploadedPhotoComplete, _amf.onRemoteFault);
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "save_jpg", responder, _uploadedPhotoByteArray, "uploadedBitmap", user.userId, _relativeUsersDirectory);
		}

		protected function onSaveUploadedPhotoComplete(argFilename:String):void
		{	
			// Subclass this method
			
			_uploadedBitmapFilename = argFilename;
				
			_isFinalResultBitmapStoredInModel = false;
			
			initializeProductAndColorSelectedIndices();
		
			loadProduct(_selectedProductIndex, _selectedColorIndex);
		}
		
		public function showCompareView():void
		{
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Compare", true);
			}
		}
		
		public function closeButtonClick():void
		{
			resetViewedFlags();
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Close", true);
			} else if (_config.banner_info.has_eyeblaster_tracking == "true") {
				EBBase.AutomaticEventCounter("Pri_Close_Click_CloseContent_OTHER");
				if (_config.banner_info.is_expanding_banner == "true")
				{
					EB.CollapsePanel("panel1", "user");	
				}
			}
		}
		
		public function adjustDotsButtonClick():void
		{
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Back_To_Adjust_Dots", true);
			}
		}
		
		public function tryOnYourOwnPhotoButtonClick():void
		{
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Try-On_Your_Own_Photo", true);
			}
		}
		
		public function adjustPhotoPosition():void
		{
			// Subclass this method
			
			showPositionPhotoView();
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Adjust_This_Photo", true);
			}
		}
		
		public function uploadNewPhoto():void
		{			
			// Subclass this method
						
			hidePositionPhotoView();
			showSelectPhotoSourceView();
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Upload_New_Photo", true);
			}
		}
		
		public function cancelUploadPhoto():void
		{
			hidePositionPhotoView();
			showSelectPhotoSourceView();
			restorePriorPositionedPhoto();
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Cancel_Upload", true);
			}
		}
		
		public function startOverButtonClick():void
		{
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Start_Over", true);
			}
		}
		
		public function nextButtonClick():void
		{			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Next", true);
			}
		}

		public function backButtonClick():void
		{
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Back", true);
			}
		}
		
		public function getStartedClick():void
		{
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Get_Started", true);
			}
		}
		
		public function storeFinalResultBitmapInModel(argBitmap:Bitmap):void
		{
			trace("Storing Final Result Bitmap In Model");
			
			_isFinalResultBitmapStoredInModel = true;
			_finalResultBitmap = argBitmap;

			dispatchEvent(new BitmapEvent(BitmapEvent.STORE_FINAL_RESULT_BITMAP_IN_MODEL_COMPLETE));
		}
		
		public function storeFeatures(data:String):void
		{
			trace("Storing features");
			
			_featuresObject = convertJSONStringToObject(data);
		}
		
		public function convertJSONStringToObject(argJSONString:String):Object
		{
			argJSONString = argJSONString.replace(/\"\((\d+),(\d+)\)\"/g, '{"x":"$1","y":"$2"}');
			var object:Object = com.adobe.serialization.json.JSON.decode(argJSONString);			
			return object;
		}
		
		public function restorePriorPositionedPhoto():void
		{
			_sourceBitmapPositionedBitmapData = _sourceBitmapPositionedBitmapDataTemp;
			
			_userSpecifiedPhotoHolderXPos = _userSpecifiedPhotoHolderXPosTemp;
			_userSpecifiedPhotoHolderYPos = _userSpecifiedPhotoHolderYPosTemp;
			_userSpecifiedPhotoHolderScaleX = _userSpecifiedPhotoHolderScaleXTemp;
			_userSpecifiedPhotoHolderScaleY = _userSpecifiedPhotoHolderScaleYTemp;
			_userSpecifiedPhotoHolderRotation = _userSpecifiedPhotoHolderRotationTemp;
		}
		
		public function restorePriorPositionedProduct():void
		{
			_userSpecifiedProductHolderXPos = _userSpecifiedProductHolderXPosTemp;
			_userSpecifiedProductHolderYPos = _userSpecifiedProductHolderYPosTemp;
			_userSpecifiedProductHolderScaleX = _userSpecifiedProductHolderScaleXTemp;
			_userSpecifiedProductHolderScaleY = _userSpecifiedProductHolderScaleYTemp;
			_userSpecifiedProductHolderRotation = _userSpecifiedProductHolderRotationTemp;
		}
		
		public function showPreloaderView():void
		{			
			if (_main.preloaderView != null)
			{
				transitionInPreloaderView();
			} else {
				_main.createPreloaderView();
			}
		}
		
		public function validateEmailAddressExists(argEmail:String)
		{
			var responder:Responder = new Responder(onValidateEmailAddressExistsCompleteHandler, _amf.onRemoteFault);
			
			showProcessingImageView("Validating Email Addresses...");
			
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "validateEmailAddressExists", responder, argEmail);
		}
		
		public function onValidateEmailAddressExistsCompleteHandler(argIsEmailAddressExist:Boolean)
		{
			hideProcessingImageView();
			
			dispatchEvent(new AbstractValidateEmailAddressExistsCompleteEvent(AbstractValidateEmailAddressExistsCompleteEvent.VALIDATE_EMAIL_ADDRESS_EXISTS_COMPLETE, argIsEmailAddressExist));
		}
		
		public function saveFinalResultBitmapOnServer():void
		{	
			trace("Saving Final Result Bitmap on Server");
			
			_finalResultByteArray = _encoder.encode(_finalResultBitmap.bitmapData);	
			
			if (_config.banner_info.has_internet_access == "true")
			{
				var responder:Responder = new Responder(onSaveFinalResultBitmapOnServerCompleteHandler, _amf.onRemoteFault);

				_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "save_jpg", responder, _finalResultByteArray, "finalResult", user.userId, _relativeUsersDirectory);
			} else {
				onSaveFinalResultBitmapOnServerCompleteHandler("demo_model.jpg");
			}
		}
		
		protected function onSaveFinalResultBitmapOnServerCompleteHandler(argFilename:String):void
		{
			_finalResultBitmapFilename = argFilename;
			
			hideProcessingImageView();
			
			dispatchEvent(new BitmapEvent(BitmapEvent.SAVE_FINAL_RESULT_BITMAP_ON_SERVER_COMPLETED));
		}
				
		/////////////////////////////////////////////////////////// SHARING AND SOCIAL MEDIA METHODS ///////////////////////////////////////////////////////////
		
		public function printFinalBitmap():void
		{
			var photoBitmap:Bitmap = new Bitmap(_finalResultBitmap.bitmapData.clone(), "auto", true);
			
			var mc:MovieClip = new MovieClip();
			mc.addChild(photoBitmap);
			
			var printJob:PrintJob = new PrintJob();
			var options:PrintJobOptions = new PrintJobOptions();
			
			options.printAsBitmap = true;
			
			if (printJob.start()) {            
				
				mc.width = printJob.pageWidth/2;
				mc.scaleY = mc.scaleX;
				
				printJob.addPage(mc, null,options);
				printJob.send();
			}
			
			mc = null;
		}
		
		public function saveToDesktop():void
		{
			var partialPathToFinalResultPhoto:String;
			partialPathToFinalResultPhoto = "\\" + _usersDirectoryName + "\\" + _user.userId + "\\" + _finalResultBitmapFilename;
			
			var url:String = _amfPhpFilePath + "download.php?partialPathToFinalResultPhoto=" + partialPathToFinalResultPhoto + "&destination_filename=" + createDownloadFilename() + ".jpg";
				
			if (!main.isSWFRunningLocally)
			{
				if (main.browser == "Firefox" || main.browser == "Internet Explorer")
				{
					if (_config.banner_info.has_doubleclick_tracking == "true")
					{
						main.enabler.exit("Save_To_Desktop_Popup", url);
					} else if (_config.banner_info.has_eyeblaster_tracking == "true") {
						EB.Clickthrough("Pri_Save_To_Desktop_Click_Clickthrough_CLICK");
						try
						{
							navigateToURL(new URLRequest(url), "_self");
						} catch (error:Error) {
							
						}
					} else {
						try
						{
							navigateToURL(new URLRequest(url), "_self");
						} catch (error:Error) {
							
						}
					}
				} else {
					if (_config.banner_info.has_doubleclick_tracking == "true")
					{
						main.enabler.exit("Save_To_Desktop_Browser", url);
					} else if (_config.banner_info.has_eyeblaster_tracking == "true") {
						EB.Clickthrough("Pri_Save_To_Desktop_Browser_Click_Clickthrough_CLICK");
						try
						{
							navigateToURL(new URLRequest(url), "_self");
						} catch (error:Error) {
							
						}
					} else {
						try
						{
							navigateToURL(new URLRequest(url), "_self");
						} catch (error:Error) {
							
						}
					}
				}
			} else {
				try
				{
					navigateToURL(new URLRequest(url), "_self");
				} catch (error:Error) {
					
				}
			}
		}
		
		public function postToFacebook():void
		{
			sendFacebookPostRequest(_facebookPhotoFilename);
		}

		public function sendFacebookPostRequest(argFilename:String):void
		{
			var title:String;
			var productURL:String;
			var caption:String;
			var summary:String;
			var sharingPhotoPath:String;
			var timeStamp:String;
			var redirectURI:String;
			
			title = _config.post_to_facebook_info.title;
			productURL = _productArray[_selectedProductIndex].colorArray[_selectedColorIndex].productURL.toString();
			
			if (productURL == "")
			{
				productURL = _config.company_info.logo_link_url;
			}
			
			if (productURL.indexOf("http://") != 0)
			{
				productURL = "http://" + productURL;
			}
			
			productURL = escape(productURL);
			
			caption = _productArray[_selectedProductIndex].productModel;
			
			var tempArray:Array = new Array();
			
			tempArray = caption.split("\\n");

			caption = tempArray.join("");
			
			redirectURI = "https://www.facebook.com/connect/login_success.html";
			
			timeStamp = getTimeStamp();
			
			summary = _config.post_to_facebook_info.summary;
			
			sharingPhotoPath = _userDirectoryURL + _user.userId + "/" + argFilename;
			
			var url:String = "https://www.facebook.com/dialog/feed?app_id="+AbstractMain.FACEBOOK_APP_ID+"&link="+productURL+"&picture="+sharingPhotoPath+"&name="+title+"&caption="+caption+"&description="+summary+"&redirect_uri="+redirectURI+"&display=popup";
			trace(url);
			
			if (!main.isSWFRunningLocally)
			{
				if (_config.banner_info.has_doubleclick_tracking == "true")
				{
					main.enabler.exit("Facebook_Share", url);
				} else if (_config.banner_info.has_eyeblaster_tracking == "true") {
					EB.Clickthrough("Pri_Facecake_Share_Click_Clickthrough_CLICK");
					_popup.getMyURL(url);
				} else {
					_popup.getMyURL(url);
				}
			} else {
				_popup.getMyURL(url);
			}
			
			hideMessageBoxView();
		}
		
		public function openURLInBrowserWindow(url:String, window:String = "_blank"):void
		{
			
			var urlRequest:URLRequest = new URLRequest(url);			
			
			if (!ExternalInterface.available) {
				
				navigateToURL(urlRequest, window);
				
			} else {
				
				var strUserAgent:String = String( ExternalInterface.call("function() {return navigator.userAgent;}") ).toLowerCase();

				if (strUserAgent.indexOf("firefox") != -1 || (strUserAgent.indexOf("msie") != -1 && uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7)) {
					
					ExternalInterface.call("window.open", url, window);
					
				} else {

					navigateToURL(urlRequest, window);
					
				}
				
			}
			
		}
		
		public function saveFacebookBitmapOnServer():void
		{
			var finalResultBitmapDataClone:BitmapData;
			var finalResultBitmapClone:Bitmap;
			var finalResultBitmapClone_mc:MovieClip;
			var facebookBitmap:Bitmap;
			var facebookBitmapByteArray:ByteArray;
			var squareCanvasWidth:Number;
			var squareCanvasHeight:Number;
			
			finalResultBitmapDataClone = _finalResultBitmap.bitmapData.clone();
			
			finalResultBitmapClone = new Bitmap(finalResultBitmapDataClone, PixelSnapping.ALWAYS, true);
			
			finalResultBitmapClone_mc = new MovieClip();
			
			finalResultBitmapClone_mc.addChild(finalResultBitmapClone);

			if (finalResultBitmapClone.width > finalResultBitmapClone.height)
			{
				
				// Landscape
				
				squareCanvasWidth = finalResultBitmapClone.width;
				squareCanvasHeight = finalResultBitmapClone.width;
				
				facebookBitmap = makeCanvasSquare(squareCanvasWidth, squareCanvasHeight, finalResultBitmapClone_mc);
				
			} else if (finalResultBitmapClone.height > finalResultBitmapClone.width) {
				
				// Portrait
				
				squareCanvasWidth = finalResultBitmapClone.height;
				squareCanvasHeight = finalResultBitmapClone.height;
				
				facebookBitmap = makeCanvasSquare(squareCanvasWidth, squareCanvasHeight, finalResultBitmapClone_mc);
			
			} else {
				
				// Square
				
				squareCanvasWidth = finalResultBitmapClone.height;
				squareCanvasHeight = finalResultBitmapClone.height;
				
				facebookBitmap = makeCanvasSquare(squareCanvasWidth, squareCanvasHeight, finalResultBitmapClone_mc);
			
			}
			
			trace("Saving Facebook Bitmap on Server");
			
			facebookBitmapByteArray = _encoder.encode(facebookBitmap.bitmapData);
			
			var responder:Responder = new Responder(onSaveFacebookBitmapOnServerCompleteHandler, _amf.onRemoteFault);
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "save_jpg", responder, facebookBitmapByteArray, "tob_facebook", user.userId, _relativeUsersDirectory);
		}
		
		protected function makeCanvasSquare(argWidth:Number, argHeight:Number, argDisplayObject:DisplayObject):Bitmap
		{
			var squareCanvasTargetWidth = 300;
			var scaleFactor:Number;
			
			if (argWidth > squareCanvasTargetWidth || argHeight > squareCanvasTargetWidth)
			{
				argWidth = squareCanvasTargetWidth;
				argHeight = squareCanvasTargetWidth;
			}
			
			var newCanvasRectangle:Rectangle = new Rectangle(0, 0, argWidth, argHeight);
			var squareCanvasBitmap:Bitmap = new Bitmap(new BitmapData(argWidth, argHeight), PixelSnapping.ALWAYS, true);
			
			var matrix:Matrix = new Matrix();
			
			if (_finalResultBitmap.width > _finalResultBitmap.height)
			{
				
				// Landscape
				
				//matrix.createBox(1, 1, 0, 0, (_finalResultBitmap.width-_finalResultBitmap.height)/2);
				//matrix.createBox(1, 1, 0, 0, (argWidth - _finalResultBitmap.height)/2);
				scaleFactor = argWidth / _finalResultBitmap.width;
				matrix.createBox(scaleFactor, scaleFactor, 0, 0, Math.abs(argHeight - _finalResultBitmap.height)/2);
				
			} else if (_finalResultBitmap.height > _finalResultBitmap.width) {
				
				// Portrait
				
				//matrix.createBox(1, 1, 0, (_finalResultBitmap.height -_finalResultBitmap.width)/2, 0);
				//matrix.createBox(1, 1, 0, (argHeight - _finalResultBitmap.width)/2, 0);
				//matrix.createBox(1, 1, 0, Math.abs(argWidth - _finalResultBitmap.width)/2, 0);
				scaleFactor = argHeight / _finalResultBitmap.height;
				matrix.createBox(scaleFactor, scaleFactor, 0, Math.abs(argWidth - scaleFactor*_finalResultBitmap.width)/2, 0);
				
			} else {
				
				// Square
				
				//matrix.createBox(1, 1, 0, 0, 0);
				scaleFactor = argWidth / _finalResultBitmap.width;
				matrix.createBox(scaleFactor, scaleFactor, 0, 0, 0);
			}
			
			squareCanvasBitmap.bitmapData.draw(argDisplayObject, matrix, null, null, newCanvasRectangle, true);

			return squareCanvasBitmap;
		}
		
		protected function onSaveFacebookBitmapOnServerCompleteHandler(argFilename:String):void
		{
			_facebookPhotoFilename = argFilename;
			
			dispatchEvent(new BitmapEvent(BitmapEvent.SAVE_FACEBOOK_BITMAP_ON_SERVER_COMPLETED));
			
		}
		
		protected function onCollapseEventHandler(event:Event):void
		{
			main.startingView = "selectPhotoSourceView";
			main.startingViewModifier = "";
			
			hideAllViews();
			
			showSelectPhotoSourceView();
		}
		
		protected function createDownloadFilename():String
		{
			var downloadFilename:String;
			var productModel:String;
			
			productModel = getSelectedProductModel();
			
			downloadFilename = getSelectedProductManufacturer() + "_";
			
			if (productModel.length > 0)
			{
				if (productModel.indexOf("\\n") != -1)
				{
					productModel = productModel.substr(0, productModel.indexOf("\\n") - 1);
				}
				
				downloadFilename += productModel + "_";
			}
			
			if (getSelectedColor().length > 0)
			{
				downloadFilename += getSelectedColor() + "_";
			}
			
			downloadFilename += getTimeStamp();
			
			return downloadFilename;
		}
		
		public function sendEmail(argSenderName:String, argSenderEmail:String, argRecipientName:String, argRecipientEmail:String, argEmailMessage:String):void
		{
			var emailSubject:String;
			
			emailSubject = _config.send_email_view.subject;
			
			
			var responder:Responder = new Responder(SendEmailCompleteHandler, _amf.onRemoteFault);
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "SendEmail", responder, _user.userId, argRecipientEmail, argRecipientName, argSenderEmail, argSenderName, emailSubject, argEmailMessage, _relativeUsersDirectory, _userDirectoryURL, _finalResultBitmapFilename, _productURL, _applicationImagesDirectoryURL, _finalResultBitmap.width, _finalResultBitmap.height);	
			
			showProcessingImageView("Sending Email");
		}
		
		protected function ValidateEmailAddressIsActiveCompleteHandler(argResult:String):void
		{
			trace("argResult = " + argResult);
		}
		
		protected function SendEmailCompleteHandler(argSuccess:int):void
		{
			hideProcessingImageView();
			
			if (argSuccess == 0)
			{
				showMessageBoxView("Email Error!  Please try again.");
			} else {
				showMessageBoxView("Email Sent!");
			}
		}
		
		/////////////////////////////////////////////////////////// END OF SHARING AND SOCIAL MEDIA METHODS ///////////////////////////////////////////////////////////
		
		public function getSelectedProductManufacturer():String
		{
			var selectedProductManufacturer:String;
			var productXMLList:XMLList;
			var tempArray:Array;			
			var myPattern:RegExp = /-/;
			var myPattern2:RegExp = /__/;
			
			productXMLList = _config..product;
			
			selectedProductManufacturer = productXMLList[_selectedProductIndex].manufacturer;
			
			tempArray = selectedProductManufacturer.split(" ");
			
			selectedProductManufacturer = tempArray.join("_");
			
			selectedProductManufacturer = selectedProductManufacturer.replace(myPattern, "");
			
			selectedProductManufacturer = selectedProductManufacturer.replace(myPattern2, "_");
			
			return selectedProductManufacturer;
		}
		
		public function getSelectedProductModel():String
		{
			var selectedProductModel:String;
			var productXMLList:XMLList;
			var tempArray:Array;			
			var myPattern:RegExp = /-/;
			var myPattern2:RegExp = /__/;
			
			productXMLList = _config..product;
			
			selectedProductModel = productXMLList[_selectedProductIndex].model;
			
			tempArray = selectedProductModel.split(" ");
			
			selectedProductModel = tempArray.join("_");
			
			selectedProductModel = selectedProductModel.replace(myPattern, "");
			
			selectedProductModel = selectedProductModel.replace(myPattern2, "_");
			
			return selectedProductModel;
		}
		
		public function getSelectedColor():String
		{
			var selectedColor:String;
			var productXMLList:XMLList;
			var colorXMLList:XMLList;
			var tempArray:Array;			
			var myPattern:RegExp = /_\/_/;
			var myPattern2:RegExp = /__/;
			
			productXMLList = _config..product;
			
			colorXMLList = productXMLList[_selectedProductIndex]..color;
			
			selectedColor = colorXMLList[_selectedColorIndex].color_description;
			
			tempArray = selectedColor.split(" ");
			
			selectedColor = tempArray.join("_");
			
			selectedColor = selectedColor.replace(myPattern, "_WITH_");
			
			selectedColor = selectedColor.replace(myPattern2, "_");	
			
			return selectedColor;
		}
		
		public function getTimeStamp():String
		{
			var date:Date;
			
			var yearNumber:Number;  
			var monthNumber:Number; 
			var dateNumber:Number;  
			var hoursNumber:Number;  
			var minutesNumber:Number;  
			var secondsNumber:Number;
			
			var yearString:String;
			var monthString:String;
			var dateString:String;
			var hoursString:String;
			var minutesString:String;
			var secondsString:String;
			
			date = new Date();
			
			yearNumber = date.getFullYear();  
			monthNumber = date.getMonth() + 1; // 0-based 
			dateNumber = date.getDate();  
			hoursNumber = date.getHours();  
			minutesNumber = date.getMinutes();  
			secondsNumber = date.getSeconds();
			
			yearString = String(yearNumber);
			
			(monthNumber < 10) ? monthString = "0" + String(monthNumber) : monthString = String(monthNumber);
			(dateNumber < 10) ? dateString = "0" + String(dateNumber) : dateString = String(dateNumber);  
			(hoursNumber < 10) ? hoursString = "0" + String(hoursNumber) : hoursString = String(hoursNumber);
			(minutesNumber < 10) ? minutesString = "0" + String(minutesNumber) : minutesString = String(minutesNumber);  
			(secondsNumber < 10) ? secondsString = "0" + String(secondsNumber) : secondsString = String(secondsNumber); 
			   
			return (monthString + "_" + dateString + "_" + yearString + "_" + hoursString + "_" + minutesString + "_" + secondsString); 
		}
		
		public function showTryOnView():void
		{
			if (_main.tryOnView != null)
			{
				transitionInTryOnView();
			} else {
				_main.createTryOnView();
			}
		}
		
		public function showSelectPhotoSourceView():void
		{
			if (_main.selectPhotoSourceView != null)
			{
				transitionInSelectPhotoSourceView();
			} else {
				_main.createSelectPhotoSourceView();
			}
		}
		
		public function showUploadFromWebcamView():void
		{
			if (_main.uploadFromWebcamView != null)
			{
				transitionInUploadFromWebcamView();
			} else {
				_main.createUploadFromWebcamView();
			}
		}
		
		public function showRegisterView():void
		{
			if (_main.registerView != null)
			{
				transitionInRegisterView();
			} else {
				_main.createRegisterView();
			}
		}
		
		public function showSelectFacebookPhotoView():void
		{
			if (_main.selectFacebookPhotoView != null)
			{
				transitionInSelectFacebookPhotoView();
			} else {
				_main.createSelectFacebookPhotoView();
			}
		}
		
		public function showPhotoTakingInstructionsView():void
		{			
			if (_main.photoTakingInstructionsView != null)
			{
				transitionInPhotoTakingInstructionsView();
			} else {
				_main.createPhotoTakingInstructionsView();
			}
		}
		
		public function showPositionPhotoView():void
		{
			if (_main.positionPhotoView != null)
			{
				transitionInPositionPhotoView();
			} else {
				_main.createPositionPhotoView();
			}
		}

		public function showProcessingImageView(argProcessingImageViewMessage:String):void
		{
			_processingImageViewMessage = argProcessingImageViewMessage;
			
			if (_main.processingImageView != null)
			{
				transitionInProcessingImageView();
			} else {
				_main.createProcessingImageView();
			}
		}
		
		public function showMessageBoxView(argMessageBoxViewMessage:String):void
		{
			_messageBoxViewMessage = argMessageBoxViewMessage;
			
			if (_main.messageBoxView != null)
			{
				transitionInMessageBoxView();
			} else {
				_main.createMessageBoxView();
			}
		}
		
		public function showCustomizeProductView():void
		{
			if (_main.customizeProductView != null)
			{
				transitionInCustomizeProductView();
			} else {
				_main.createCustomizeProductView();
			}
		}
		
		public function showShareProductView():void
		{
			if (_main.shareProductView != null)
			{
				transitionInShareProductView();
			} else {
				_main.createShareProductView();
			}
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Share", true);
			}
		}
		
		public function showSendEmailView():void
		{
			if (_main.sendEmailView != null)
			{
				transitionInSendEmailView();
			} else {
				_main.createSendEmailView();
			}
			
			if (_config.banner_info.has_doubleclick_tracking == "true")
			{
				main.enabler.counter("Email", true);
			}
		}
		
		public function hideTryOnView():void
		{
			transitionOutTryOnView();
		}
		
		public function hideSelectPhotoSourceView():void
		{
			transitionOutSelectPhotoSourceView();
		}		
		
		public function hideUploadFromWebcamView():void
		{
			transitionOutUploadFromWebcamView();
		}
		
		public function hideRegisterView():void
		{
			transitionOutRegisterView();
		}
		
		public function hideSelectFacebookPhotoView():void
		{
			transitionOutSelectFacebookPhotoView();
		}
		
		public function hidePhotoTakingInstructionsView():void
		{
			transitionOutPhotoTakingInstructionsView();
		}
		
		public function hidePositionPhotoView():void
		{
			transitionOutPositionPhotoView();
		}
		
		public function hideProcessingImageView():void
		{
			transitionOutProcessingImageView();
		}
		
		public function hideMessageBoxView():void
		{
			transitionOutMessageBoxView();
		}
		
		public function hideCustomizeProductView():void
		{
			transitionOutCustomizeProductView();
		}
		
		public function hideShareProductView():void
		{
			transitionOutShareProductView();
		}
		
		public function hideSendEmailView():void
		{
			transitionOutSendEmailView();
		}
		
		public function hideAllViews():void
		{
			_isUploadFromWebcam = false;
			_isUploadFromComputer = false;
			_isUploadFromFacebook = false;
			_isUseDemoModel = false;

			hideSelectPhotoSourceView();
			hideRegisterView();
			hideSelectFacebookPhotoView();
			hidePhotoTakingInstructionsView();
			hidePositionPhotoView();
			hideProcessingImageView();
			hideMessageBoxView();
			hideCustomizeProductView();
			hideShareProductView();
			hideSendEmailView();
			
			showTryOnView();
		}
		
		public function resetViewedFlags():void
		{
			_hasTryOnViewBeenViewed = false;
			_hasSelectPhotoSourceViewBeenViewed = false;
			_isViewedPhotoTakingInstructions = false;
			main.startingView = "";
			main.startingViewModifier = "";
		}
		
		public function getIPAddress():String
		{
			return _tracking.getIPAddress();
		}

		public function track(argPageName:String, argDefaultPage:String, argAction:String, argActionDescriptor:String,  argEmail:String = "-1", argAppliedValue:String = "-1", argAppliedAssetID:String = "-1", argAppliedToImageID:String = "-1", argAppliedAssetIDList:String = "-1"):void
		{
			if (_config.banner_info.has_facecake_tracking == "true" && _config.banner_info.has_internet_access == "true")
			{
				_tracking.track(argPageName, argDefaultPage, argAction, argActionDescriptor, argEmail, argAppliedValue, argAppliedAssetID, argAppliedToImageID, argAppliedAssetIDList);
			}
		}
		
		/////////////////////////////////////////////////////////// TRANSITION METHODS ///////////////////////////////////////////////////////////
		
		public function transitionInTryOnView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_TRYON_VIEW));
		}
		
		public function transitionOutTryOnView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_TRYON_VIEW));
		}		
		
		public function transitionInPreloaderView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_PRELOADER_VIEW));
		}
		
		public function transitionOutPreloaderView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_PRELOADER_VIEW));
		}
		
		public function transitionInSelectPhotoSourceView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_SELECT_PHOTO_SOURCE_VIEW));
		}	
		
		public function transitionOutSelectPhotoSourceView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_SELECT_PHOTO_SOURCE_VIEW));
		}	
		
		public function transitionInUploadFromWebcamView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_UPLOAD_FROM_WEBCAM_VIEW));
		}
		
		public function transitionOutUploadFromWebcamView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_UPLOAD_FROM_WEBCAM_VIEW));
		}
		
		public function transitionInSelectFacebookPhotoView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_SELECT_FACEBOOK_PHOTO_VIEW));
		}	
		
		public function transitionOutSelectFacebookPhotoView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_SELECT_FACEBOOK_PHOTO_VIEW));
		}
		
		public function transitionInRegisterView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_REGISTER_VIEW));
		}	
		
		public function transitionOutRegisterView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_REGISTER_VIEW));
		}
		
		public function transitionInPhotoTakingInstructionsView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_PHOTO_TAKING_INSTRUCTIONS_VIEW));
		}	
		
		public function transitionOutPhotoTakingInstructionsView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_PHOTO_TAKING_INSTRUCTIONS_VIEW));
		}
		
		public function transitionInPositionPhotoView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_POSITION_PHOTO_VIEW));
		}	
		
		public function transitionOutPositionPhotoView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_POSITION_PHOTO_VIEW));
		}
		
		public function transitionInProcessingImageView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_PROCESSING_IMAGE_VIEW));
		}	
		
		public function transitionOutProcessingImageView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_PROCESSING_IMAGE_VIEW));
		}
		
		public function transitionInCustomizeProductView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_CUSTOMIZE_PRODUCT_VIEW));
		}	
		
		public function transitionOutCustomizeProductView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_CUSTOMIZE_PRODUCT_VIEW));
		}
		
		public function transitionInShareProductView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_SHARE_PRODUCT_VIEW));
		}	
		
		public function transitionOutShareProductView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_SHARE_PRODUCT_VIEW));
		}			
		
		public function transitionInSendEmailView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_SEND_EMAIL_VIEW));
		}	
		
		public function transitionOutSendEmailView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_SEND_EMAIL_VIEW));
		}			
		
		public function transitionInMessageBoxView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_MESSAGE_BOX_VIEW));
		}	
		
		public function transitionOutMessageBoxView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_MESSAGE_BOX_VIEW));
		}
		
		/////////////////////////////////////////////////////////// END OF TRANSITION METHODS ///////////////////////////////////////////////////////////
		
		override protected function updateData () : void
		{
			
			dispatchEvent(new Event(Model.MODEL_CHANGE));
			
			trace("AbstractTryOnModel Updated");
			
		}
		
		// GETTERS AND SETTERS
		
		public function get facebookAppID():String
		{
			return _facebookAppID;
		}
		
		public function get isUseDemoModel():Boolean
		{
			return _isUseDemoModel;
		}
		
		public function get baseURL():String
		{
			return _baseURL;
		}
		
		public function get config():XML
		{
			return _config;
		}
		
		public function get amf():AMFPHP
		{
			return _amf;
		}
		
		public function get amfPhpFilePath():String
		{
			return _amfPhpFilePath;
		}
		
		public function get sessionID():int
		{
			return _sessionID;
		}
		
		public function get templateID():String
		{
			return _templateID;
		}
		
		public function get facecakeAppID():String
		{
			return _facecakeAppID;
		}
		
		public function get relativeTemplatesDirectory():String
		{
			return _relativeTemplatesDirectory;
		}
		
		public function get usersDirectoryName():String
		{
			return _usersDirectoryName;
		}
		
		public function get relativeUsersDirectory():String
		{
			return _relativeUsersDirectory;
		}
		
		public function get userDirectoryURL():String
		{
			return _userDirectoryURL;
		}
		
		public function get applicationImagesDirectoryURL():String
		{
			return _applicationImagesDirectoryURL;
		}
		
		public function get isUserInteractedWithBanner():Boolean
		{
			return _isUserInteractedWithBanner;
		}
		
		public function set isUserInteractedWithBanner(value:Boolean):void
		{
			_isUserInteractedWithBanner = value;
		}
		
		public function get main():Object
		{
			return _main;
		}
		
		public function set facebookAppID(value:String):void
		{
			_facebookAppID = value;
		}
		
		public function set facebookScope(value:String):void
		{
			_facebookScope = value;
		}
		
		public function set isUseDemoModel(value:Boolean):void
		{
			_isUseDemoModel = value;
		}
		
		public function set baseURL(value:String):void
		{
			_baseURL = value;
		}
		
		public function set config(value:XML):void
		{
			_config = value;
		}
		
		public function set amf(value:AMFPHP):void
		{
			_amf = value;
		}
		
		public function set amfPhpFilePath(value:String):void
		{
			_amfPhpFilePath = value;
		}
		
		public function set sessionID(value:int):void
		{
			_sessionID = value;
		}
		
		public function set tracking(value:Tracking):void
		{
			_tracking = value;
		}
		
		public function set templateID(value:String):void
		{
			_templateID = value;
		}
		
		public function set facecakeAppID(value:String):void
		{
			_facecakeAppID = value;
		}
		
		public function set relativeTemplatesDirectory(value:String):void
		{
			_relativeTemplatesDirectory = value;
		}
		
		public function set usersDirectoryName(value:String):void
		{
			_usersDirectoryName = value;
		}
		
		public function set relativeUsersDirectory(value:String):void
		{
			_relativeUsersDirectory = value;
		}
		
		public function set userDirectoryURL(value:String):void
		{
			_userDirectoryURL = value;
		}	
		
		public function set applicationImagesDirectoryURL(value:String):void
		{
			_applicationImagesDirectoryURL = value;
		}
		
		public function set main(value:Object):void
		{
			_main = value;
		}
		
		public function set sourceBitmap(value:Bitmap):void
		{
			_sourceBitmap = value;
		}
		
		public function set selectedProductIndex(value:int):void
		{
			_selectedProductIndex = value;

			loadProduct(_selectedProductIndex, 0);
		}
		
		public function set selectedColorIndex(value:int):void
		{
			_selectedColorIndex = value;

			loadProduct(_selectedProductIndex, _selectedColorIndex);
		}
		
		public function get localSharedObject():SharedObject
		{
			return _localSharedObject;
		}
		
		public function get uploadedBitmapFilename():String
		{
			return _uploadedBitmapFilename;
		}
		
		public function set uploadedBitmapFilename(value:String):void
		{
			_uploadedBitmapFilename = value;
		}
		
		public function get finalResultBitmapFilename():String
		{
			return _finalResultBitmapFilename;
		}
		
		public function set finalResultBitmapFilename(value:String):void
		{
			_finalResultBitmapFilename = value;
		}
		
		public function get emailBitmapFilename():String
		{
			return _emailBitmapFilename;
		}
		
		public function set emailBitmapFilename(value:String):void
		{
			_emailBitmapFilename = value;
		}
		
		public function get productArray():Array
		{
			return _productArray;
		}
		
		public function get selectedProductIndex():int
		{
			return _selectedProductIndex;
		}
		
		public function get selectedColorIndex():int
		{
			return _selectedColorIndex;
		}
		
		public function get sourceBitmap():Bitmap
		{
			return _sourceBitmap;
		}
		
		public function set featuresObject(value:Object):void
		{
			_featuresObject = value;
		}
		
		public function get featuresObject():Object
		{
			return _featuresObject;
		}
		
		public function set sourceBitmapPositionedBitmapData(value:BitmapData):void
		{
			// Store current photo in case it needs to be restored i.e. After failed feature recognition of new photo
			_sourceBitmapPositionedBitmapDataTemp = _sourceBitmapPositionedBitmapData;
			
			_sourceBitmapPositionedBitmapData = value;
		}
		
		public function get sourceBitmapPositionedBitmapData():BitmapData
		{
			return _sourceBitmapPositionedBitmapData;
		}
		
		public function get sourceBitmapPositionedBitmapDataTemp():BitmapData
		{
			return _sourceBitmapPositionedBitmapDataTemp;
		}
		
		public function get productBitmap():Bitmap
		{
			return _productBitmap;
		}
		
		public function set productBitmap(value:Bitmap):void
		{
			_productBitmap = value;
		}
		
		public function get finalResultBitmap():Bitmap
		{
			return _finalResultBitmap;
		}
		
		public function set finalResultBitmap(value:Bitmap):void
		{
			_finalResultBitmap = value;
			dispatchEvent(new BitmapEvent(BitmapEvent.STORE_FINAL_RESULT_BITMAP_IN_MODEL_COMPLETE));
		}		
		
		public function get isFinalResultBitmapStoredInModel():Boolean
		{
			return _isFinalResultBitmapStoredInModel;
		}
		
		public function set isFinalResultBitmapStoredInModel(value:Boolean):void
		{
			_isFinalResultBitmapStoredInModel = value;
		}
		
		public function get user():User
		{
			return _user;
		}
		
		public function set user(value:User):void
		{
			_user = value;
		}
		
		public function get isRegistered():Boolean
		{
			return _isRegistered;
		}
		
		public function set isRegistered(value:Boolean):void
		{
			_isRegistered = value;
		}
		
		public function get isViewedPhotoTakingInstructions():Boolean
		{
			return _isViewedPhotoTakingInstructions;
		}
		
		public function set isViewedPhotoTakingInstructions(value:Boolean):void
		{
			_isViewedPhotoTakingInstructions = value;
		}
		
		public function get hasTryOnViewBeenViewed():Boolean
		{
			return _hasTryOnViewBeenViewed;
		}
		
		public function set hasTryOnViewBeenViewed(value:Boolean):void
		{
			_hasTryOnViewBeenViewed = value;
		}
		
		public function get hasSelectPhotoSourceViewBeenViewed():Boolean
		{
			return _hasSelectPhotoSourceViewBeenViewed;
		}
		
		public function set hasSelectPhotoSourceViewBeenViewed(value:Boolean):void
		{
			_hasSelectPhotoSourceViewBeenViewed = value;
		}
				
		/////////////// User Specified Parameters  -  Photo Holder ///////////////////////////
		
		public function get userSpecifiedPhotoHolderXPos():Number
		{
			return _userSpecifiedPhotoHolderXPos;
		}
		
		public function set userSpecifiedPhotoHolderXPos(value:Number):void
		{
			// Store existing photo holder parameters in case feature recognition fails and the original photo holder parameters need to be restored
			_userSpecifiedPhotoHolderXPosTemp = _userSpecifiedPhotoHolderXPos;
			
			_userSpecifiedPhotoHolderXPos = value;
		}
		
		public function get userSpecifiedPhotoHolderYPos():Number
		{
			return _userSpecifiedPhotoHolderYPos;
		}
		
		public function set userSpecifiedPhotoHolderYPos(value:Number):void
		{
			// Store existing photo holder parameters in case feature recognition fails and the original photo holder parameters need to be restored
			_userSpecifiedPhotoHolderYPosTemp = _userSpecifiedPhotoHolderYPos;
			
			_userSpecifiedPhotoHolderYPos = value;
		}
		
		public function get userSpecifiedPhotoHolderScaleX():Number
		{
			return _userSpecifiedPhotoHolderScaleX;
		}
		
		public function set userSpecifiedPhotoHolderScaleX(value:Number):void
		{
			// Store existing photo holder parameters in case feature recognition fails and the original photo holder parameters need to be restored
			_userSpecifiedPhotoHolderScaleXTemp = _userSpecifiedPhotoHolderScaleX;
			
			_userSpecifiedPhotoHolderScaleX = value;
		}
		
		public function get userSpecifiedPhotoHolderScaleY():Number
		{
			return _userSpecifiedPhotoHolderScaleY;
		}
		
		public function set userSpecifiedPhotoHolderScaleY(value:Number):void
		{
			// Store existing photo holder parameters in case feature recognition fails and the original photo holder parameters need to be restored
			_userSpecifiedPhotoHolderScaleYTemp = _userSpecifiedPhotoHolderScaleY;
			
			_userSpecifiedPhotoHolderScaleY = value;
		}
		
		public function get userSpecifiedPhotoHolderRotation():Number
		{
			return _userSpecifiedPhotoHolderRotation;
		}
		
		public function set userSpecifiedPhotoHolderRotation(value:Number):void
		{
			// Store existing photo holder parameters in case feature recognition fails and the original photo holder parameters need to be restored
			_userSpecifiedPhotoHolderRotationTemp = _userSpecifiedPhotoHolderRotation;
			
			_userSpecifiedPhotoHolderRotation = value;
		}
		
		/////////////// User Specified Parameters  -  Product Holder ///////////////////////////

		public function get userSpecifiedProductHolderXPos():Number
		{
			return _userSpecifiedProductHolderXPos;
		}
		
		public function set userSpecifiedProductHolderXPos(value:Number):void
		{
			// Store existing product holder parameters in case user drags product out of boundaries and the original photo holder parameters need to be restored
			_userSpecifiedProductHolderXPosTemp = _userSpecifiedProductHolderXPos;
			
			_userSpecifiedProductHolderXPos = value;
		}
		
		public function get userSpecifiedProductHolderYPos():Number
		{
			return _userSpecifiedProductHolderYPos;
		}
		
		public function set userSpecifiedProductHolderYPos(value:Number):void
		{
			// Store existing product holder parameters in case user drags product out of boundaries and the original photo holder parameters need to be restored
			_userSpecifiedProductHolderYPosTemp = _userSpecifiedProductHolderYPos;
			
			_userSpecifiedProductHolderYPos = value;
		}
		
		public function get userSpecifiedProductHolderScaleX():Number
		{
			return _userSpecifiedProductHolderScaleX;
		}
		
		public function set userSpecifiedProductHolderScaleX(value:Number):void
		{
			// Store existing product holder parameters in case user drags product out of boundaries and the original photo holder parameters need to be restored
			_userSpecifiedProductHolderScaleXTemp = _userSpecifiedProductHolderScaleX;
			
			_userSpecifiedProductHolderScaleX = value;
		}
		
		public function get userSpecifiedProductHolderScaleY():Number
		{
			return _userSpecifiedProductHolderScaleY;
		}
		
		public function set userSpecifiedProductHolderScaleY(value:Number):void
		{
			// Store existing product holder parameters in case user drags product out of boundaries and the original photo holder parameters need to be restored
			_userSpecifiedProductHolderScaleYTemp = _userSpecifiedProductHolderScaleY;
			
			_userSpecifiedProductHolderScaleY = value;
		}
		
		public function get userSpecifiedProductHolderRotation():Number
		{
			return _userSpecifiedProductHolderRotation;
		}
		
		public function set userSpecifiedProductHolderRotation(value:Number):void
		{
			// Store existing product holder parameters in case user drags product out of boundaries and the original photo holder parameters need to be restored
			_userSpecifiedProductHolderRotationTemp = _userSpecifiedProductHolderRotation;
			
			_userSpecifiedProductHolderRotation = value;
		}
		
		/////////////// User Specified Paramters  -  TEMP  -  Photo Holder ////////////////////////////////////////////
				
		public function get userSpecifiedPhotoHolderXPosTemp():Number
		{
			return _userSpecifiedPhotoHolderXPosTemp;
		}
		
		public function get userSpecifiedPhotoHolderYPosTemp():Number
		{
			return _userSpecifiedPhotoHolderYPosTemp;
		}
		
		public function get userSpecifiedPhotoHolderScaleXTemp():Number
		{
			return _userSpecifiedPhotoHolderScaleXTemp;
		}
		
		public function get userSpecifiedPhotoHolderScaleYTemp():Number
		{
			return _userSpecifiedPhotoHolderScaleYTemp;
		}
		
		public function get userSpecifiedPhotoHolderRotationTemp():Number
		{
			return _userSpecifiedPhotoHolderRotationTemp;
		}
		
		/////////////// User Specified Paramters  -  TEMP  -  Product Holder ////////////////////////////////////////////
		
		public function get userSpecifiedProductHolderXPosTemp():Number
		{
			return _userSpecifiedProductHolderXPosTemp;
		}
		
		public function get userSpecifiedProductHolderYPosTemp():Number
		{
			return _userSpecifiedProductHolderYPosTemp;
		}
		
		public function get userSpecifiedProductHolderScaleXTemp():Number
		{
			return _userSpecifiedProductHolderScaleXTemp;
		}
		
		public function get userSpecifiedProductHolderScaleYTemp():Number
		{
			return _userSpecifiedProductHolderScaleYTemp;
		}
		
		public function get userSpecifiedProductHolderRotationTemp():Number
		{
			return _userSpecifiedProductHolderRotationTemp;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		public function set processingImageViewMessage(value:String):void
		{
			_processingImageViewMessage = value;
		}
		
		public function get processingImageViewMessage():String
		{
			return _processingImageViewMessage;
		}	
		
		
		public function set emailSenderName(value:String):void
		{
			_emailSenderName = value;
		}
		
		public function get emailSenderName():String
		{
			return _emailSenderName;
		}
		
		public function set emailSenderEmailAddress(value:String):void
		{
			_emailSenderEmailAddress = value;
		}
		
		public function get emailSenderEmailAddress():String
		{
			return _emailSenderEmailAddress;
		}
		
		public function set emailRecipientName(value:String):void
		{
			_emailRecipientName = value;
		}
		
		public function get emailRecipientName():String
		{
			return _emailRecipientName;
		}
		
		public function set emailRecipientEmailAddress(value:String):void
		{
			_emailRecipientEmailAddress = value;
		}
		
		public function get emailRecipientEmailAddress():String
		{
			return _emailRecipientEmailAddress;
		}
		
		public function set emailBody(value:String):void
		{
			_emailBody = value;
		}
		
		public function get emailBody():String
		{
			return _emailBody;
		}
		
		public function set defaultEmailMessage(value:String):void
		{
			_defaultEmailMessage = value;
		}
		
		public function get defaultEmailMessage():String
		{
			return _defaultEmailMessage;
		}
		
		public function get isUserOptIn():Boolean
		{
			return _isUserOptIn;
		}
		
		public function set isUserOptIn(value:Boolean):void
		{
			_isUserOptIn = value;
		}	
		
		public function get lastItemClickedOn():String
		{
			return _lastItemClickedOn;
		}
		
		public function set lastItemClickedOn(value:String):void
		{
			_lastItemClickedOn = value;
		}
		
		public function get lastItemClickedOnProductViewId():String
		{
			return _lastItemClickedOnProductViewId;
		}
		
		public function set lastItemClickedOnProductViewId(value:String):void
		{
			_lastItemClickedOnProductViewId = value;
		}
		
		public function set selectedFacebookAlbumPhotoURLArray(value:Array):void
		{
			_selectedFacebookAlbumPhotoURLArray = value;
		}
		
		public function get selectedFacebookAlbumPhotoURLArray():Array
		{
			return _selectedFacebookAlbumPhotoURLArray;
		}
		
		public function get facebookAlbumsArray():Array
		{
			return _facebookAlbumsArray;
		}
		
		public function set selectedFacebookPhotoURL(value:String):void
		{
			_selectedFacebookPhotoURL = value;
		}
		
		public function get selectedFacebookPhotoURL():String
		{
			return _selectedFacebookPhotoURL;
		}
		
		public function set loggedIntoFacebook(value:Boolean):void
		{
			_loggedIntoFacebook = value;
		}
		
		public function get loggedIntoFacebook():Boolean
		{
			return _loggedIntoFacebook;
		}
		
		public function set messageBoxViewMessage(value:String):void
		{
			_messageBoxViewMessage = value;
		}
		
		public function get messageBoxViewMessage():String
		{
			return _messageBoxViewMessage;
		}
		
		public function get isUploadFromWebcam():Boolean
		{
			return _isUploadFromWebcam;
		}
		
		public function set isUploadFromWebcam(value:Boolean):void
		{
			_isUploadFromWebcam = value;
		}
		
		public function get isUploadFromComputer():Boolean
		{
			return _isUploadFromComputer;
		}
		
		public function set isUploadFromComputer(value:Boolean):void
		{
			_isUploadFromComputer = value;
		}
		
		public function get isUploadFromFacebook():Boolean
		{
			return _isUploadFromFacebook;
		}
		
		public function set isUploadFromFacebook(value:Boolean):void
		{
			_isUploadFromFacebook = value;
		}
		
		public function get objectsDetectedJSONString():String
		{
			return _objectsDetectedJSONString;
		}
		
		public function set objectsDetectedJSONString(value:String):void
		{
			_objectsDetectedJSONString = value;
		}

		public function get objectRecognitionBitmapData():BitmapData
		{
			return _objectRecognitionBitmapData;
		}

		public function set objectRecognitionBitmapData(value:BitmapData):void
		{
			_objectRecognitionBitmapData = value;
		}
		
		public function get objectRecognitionBitmap():Bitmap
		{
			return _objectRecognitionBitmap;
		}
		
		public function set objectRecognitionBitmap(value:Bitmap):void
		{
			_objectRecognitionBitmap = value;
		}

		public function get facebookPhotoFilename():String
		{
			return _facebookPhotoFilename;
		}

		public function set facebookPhotoFilename(value:String):void
		{
			_facebookPhotoFilename = value;
		}

		public function get recommendedProductViewIdsArray():Array
		{
			return _recommendedProductViewIdsArray;
		}

		public function set recommendedProductViewIdsArray(value:Array):void
		{
			_recommendedProductViewIdsArray = value;
		}

		public function get isShowOkButtonOnMessageBoxView():Boolean
		{
			return _isShowOkButtonOnMessageBoxView;
		}

		public function set isShowOkButtonOnMessageBoxView(value:Boolean):void
		{
			_isShowOkButtonOnMessageBoxView = value;
		}
		
	}
	
}