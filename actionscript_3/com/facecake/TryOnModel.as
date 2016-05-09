package com.facecake.tryon.model
{
	
	import com.facecake.tryon.abstract.main.AbstractMain;
	import com.facecake.tryon.abstract.model.AbstractTryOnModel;
	import com.facecake.tryon.events.TransitionEvent;
	import com.facecake.tryon.mvc.Model;
	import com.facecake.utils.GenerateGUID;
	import com.facecake.utils.HTTPCookies;
	import com.greensock.events.TransformEvent;
	import com.greensock.transform.TransformItem;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	
	/**
	 * Concrete MVC Model to store Try-On data
	 */
	public class TryOnModel extends AbstractTryOnModel
	{
		
		public static const PHOTO_MASK_WIDTH:Number = CONFIG::PHOTO_MASK_WIDTH;
		public static const PHOTO_MASK_HEIGHT:Number = CONFIG::PHOTO_MASK_HEIGHT;
		
		public static const FINAL_RESULT_BITMAP_WIDTH:Number = CONFIG::FINAL_RESULT_BITMAP_WIDTH;
		public static const FINAL_RESULT_BITMAP_HEIGHT:Number = CONFIG::FINAL_RESULT_BITMAP_HEIGHT;
		
		private static var _instance:TryOnModel;	
		
		private var _numberOfInvalidThumbnailFilenames:int;
		
		private var _setupProducts:Boolean;
		
		public function TryOnModel ()
		{			
			super(PHOTO_MASK_WIDTH, PHOTO_MASK_HEIGHT, FINAL_RESULT_BITMAP_WIDTH, FINAL_RESULT_BITMAP_HEIGHT);
			
			trace("TryOnModel Instantiated");
		}
		
		public static function getInstance () : TryOnModel
		{
			if (_instance == null)
			{
				TryOnModel._instance = new TryOnModel ();
			}
			return TryOnModel._instance;
		}
		
		override protected function initialize():void
		{			
			_setupProducts = false;
			
			super.initialize();
		}
		
		
		// Select photo source methods
		
		override public function uploadFromWebcam():void
		{
			super.uploadFromWebcam();
			
			if (_isRegistered)
			{				
				hideTryOnView();
				hideSelectPhotoSourceView();
				showUploadFromWebcamView();
			} else {
				showRegisterView();
			}
		}
		
		override public function uploadFromComputer():void
		{
			super.uploadFromComputer();
			
			if (_isRegistered)
			{
				if (_isViewedPhotoTakingInstructions)
				{
					browseLocalPhotos();
				} else {
					hideTryOnView();
					hideSelectPhotoSourceView();
					showPhotoTakingInstructionsView();
				}
			} else {
				showRegisterView();
			}
		}
		
		override protected function onLoadPhotoCompleteHandler(event:Event):void
		{
			_setupProducts = true;

			super.onLoadPhotoCompleteHandler(event);
		}
		
		override protected function onSaveUploadedPhotoComplete(argFilename:String):void
		{			
			super.uploadedBitmapFilename = argFilename;
			
			super.isFinalResultBitmapStoredInModel = false;
			
			super.initializeProductAndColorSelectedIndices();
			
			detectFacialFeatures();
		}
		
		private function detectFacialFeatures():void
		{
			trace("Detecting Facial Features");

			var responder:Responder = new Responder(onDetectFacialFeaturesComplete, _amf.onRemoteFault);
			_amf.connection.call(AbstractMain.DATA_ACCESS_DESCRIPTOR + "." + "detect_facial_features", responder, _uploadedBitmapFilename, user.userId, _relativeUsersDirectory);
					
		}
		
		private function onDetectFacialFeaturesComplete(data:String):void
		{			
			hideProcessingImageView();
			
			if (data != '{"faceresults":{}}') {				
				trace("Features detected");
				storeFeatures(data);
				makeFaceClosestTotheCenterofThePhotoTheRelevantFace();
				hideUploadFromWebcamView();
				hidePositionPhotoView();				
				showAdjustRecognitionResultView();
			} else {
				trace("No features detected!");
				if (_isUploadFromWebcam == true)
				{
					showMessageBoxView("No faces found.  Try Again!");
					dispatchEvent(new Event("resetCaptureBitmapAndCaptureButton", true));
				} else {
					showUndetectedFeaturesView();
				}
			}
		}
		
		override public function storeFeatures(data:String):void
		{
			super.storeFeatures(data);
		}
		
		private function makeFaceClosestTotheCenterofThePhotoTheRelevantFace()
		{
			var radialDistanceArray = new Array();
			
			var radialDistance:Number;
			
			var centerPoint:Point = new Point(CONFIG::PHOTO_MASK_WIDTH/2, CONFIG::PHOTO_MASK_HEIGHT/2);
			
			var leftEyePoint:Point;
			
			// Create array of values representing distance of left eye from center of photo for each face detected
			for (var face:Object in _featuresObject.faceresults)
			{	
				var leftEyePointX:Number = Number(_featuresObject.faceresults[face].lefteye.position.x);
				var leftEyePointY:Number = Number(_featuresObject.faceresults[face].lefteye.position.y);
				
				leftEyePoint = new Point(leftEyePointX, leftEyePointY);
				
				radialDistance = Point.distance(leftEyePoint, centerPoint);
				
				radialDistanceArray.push(radialDistance);
			}
			
			var smallestDistance:Number = Point(new Point(CONFIG::PHOTO_MASK_WIDTH, CONFIG::PHOTO_MASK_HEIGHT)).length;
			var smallestDistanceIndex:int = 0;
			
			// Determine the index of the face in the _featuresObject whose left eye is closest to the center of the photo
			for (var j:int = 0; j < radialDistanceArray.length; j++)
			{
				if (radialDistanceArray[j] < smallestDistance)
				{
					smallestDistance = radialDistanceArray[j];
					smallestDistanceIndex = j;
				}
			}		
			
			var index:int = 0;
			
			// Set the first face in the _featuresObject equal to the face that is closest to the center of the photo to assure product appears in correct position in final result 
			for (var face:Object in _featuresObject.faceresults)
			{				
				if (index == smallestDistanceIndex)
				{
					_featuresObject.faceresults.face0 = _featuresObject.faceresults[face];
				}
				
				index++;
			}
		}
		
		public function setLeftEyePosition(argLeftEyeXPos:Number, argLeftEyeYPos:Number):void
		{
			super.featuresObject.faceresults.face0.lefteye.position.x = argLeftEyeXPos;
			super.featuresObject.faceresults.face0.lefteye.position.y = argLeftEyeYPos;
		}
		
		public function setRightEyePosition(argRightEyeXPos:Number, argRightEyeYPos:Number):void
		{
			super.featuresObject.faceresults.face0.righteye.position.x = argRightEyeXPos;
			super.featuresObject.faceresults.face0.righteye.position.y = argRightEyeYPos;
		}
		
		public function getRecommendedProductViewIds(argGender:String = CONFIG::DEMO_MODEL_GENDER, argFaceShape:String = CONFIG::DEMO_MODEL_FACE_SHAPE, argSkinUndertone:String = CONFIG::DEMO_MODEL_SKIN_UNDERTONE):void
		{
			trace("Getting Recommended Product View Id's");
			
			var urlLoader:URLLoader = new URLLoader();
			
			urlLoader.addEventListener(Event.COMPLETE, onGetRecommendedProductViewIdsCompleteHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorHandler);
			
			var userGuid:String = HTTPCookies.getCookie('userGUID');
			
			if (userGuid == null)
			{
				userGuid = GenerateGUID.create();	
			}
			
			// Since "long" is not used in our database for face shape 
			// TODO: Remove these if statements if detection includes long as a face shape
			
			if (argFaceShape == "long")
			{
				argFaceShape = "oval";
			}

			if (_featuresObject)
			{				
				if (_featuresObject.faceresults.face0.faceshape.shape == "long")
				{
					_featuresObject.faceresults.face0.faceshape.shape = "oval";
				}
			}
			
			populateRealtimeProfileValues();
			
			var urlRequest = new URLRequest("getRecs.php?app_id=" + _facecakeAppID + "&user_guid=" + userGuid + "&gender=" + argGender + "&face_shape=" + argFaceShape + "&skin_undertone=" + argSkinUndertone + "&domain_id=6&ret_type=XML&signed=0");
			
			urlLoader.load(urlRequest);
		}
		
		protected function onGetRecommendedProductViewIdsCompleteHandler(event:Event):void
		{			
			event.currentTarget.removeEventListener(Event.COMPLETE, onGetRecommendedProductViewIdsCompleteHandler);
			
			var data:String = String(event.target.data);
			
			if (data != '{}' && data != '{"recommendations": []}') {
				
				trace("Recommended Product View Id(s) returned successfully");
				
				var recommendedProductViewIdsJSONString = data;
				
				var recommendedProductViewIdsObject = new Object();
				
				recommendedProductViewIdsObject = convertJSONStringToObject(data);
				
			} else {
				
				trace("No recommended Product View Id(s) returned!");
				
				hideCustomizeProductView();
				
				showSelectPhotoSourceView();
				
				showMessageBoxView("No recommended products found.");
				
				return;
				
			}
			
			_recommendedProductViewIdsArray = null;
			
			_recommendedProductViewIdsArray = new Array();
			
			for (var recommendation:Object in recommendedProductViewIdsObject.recommendations)
			{	
				_recommendedProductViewIdsArray.push(recommendedProductViewIdsObject.recommendations[recommendation].product_view_id);
			}
			
			updateData();
			
			dispatchEvent(new Event("get recommended product view ids completed"));
		}
		
		public function populateRealtimeProfileValues(argFilter:String = "recommended"):void
		{
			clearRealtimeProfileValues();
			
			if (_isUseDemoModel == true)
			{
				if(_config.banner_info.has_recommendations == true && _main.gender_txt != null)
				{
					_main.gender_txt.text = CONFIG::DEMO_MODEL_GENDER;
				}
				
				if (argFilter == "recommended")
				{
					if (_config.banner_info.has_recommendations == true)
					{
						if (_main.faceShape_txt != null)
						{
							_main.faceShape_txt.text = CONFIG::DEMO_MODEL_FACE_SHAPE;
						}
						
						if (_main.skinUndertone_txt != null)
						{
							_main.skinUndertone_txt.text = CONFIG::DEMO_MODEL_SKIN_UNDERTONE;;
						}						
					}
				} else if (argFilter == "all") {
					if (_config.banner_info.has_recommendations == true)
					{
						if (_main.faceShape_txt != null)
						{
							_main.faceShape_txt.text = "all";
						}
						
						if (_main.skinUndertone != null)
						{
							_main.skinUndertone_txt.text = "all";
						}
					}
				}				
			} else {
				
				// TODO: Remove this if statement if service recognizes and returns "long" as a face shape.
				if (_featuresObject)
				{				
					if (_featuresObject.faceresults.face0.faceshape.shape == "long")
					{
						_featuresObject.faceresults.face0.faceshape.shape = "oval";
					}
				}
				
				if(_config.banner_info.has_recommendations == true && _main.gender_txt != null)
				{
					_main.gender_txt.text = _user.gender;
				}
				
				if (argFilter == "recommended")
				{
					if (_config.banner_info.has_recommendations == true)
					{
						if (_main.faceShape_txt != null)
						{
							_main.faceShape_txt.text = _featuresObject.faceresults.face0.faceshape.shape;
						}
						
						if (_main.skinUndertone_txt != null)
						{
							_main.skinUndertone_txt.text = _featuresObject.faceresults.face0.skintone.undertone;
						}
					}
				} else if (argFilter == "all") {
					if (_config.banner_info.has_recommendations == true)
					{
						if (_main.faceShape_txt)
						{
							_main.faceShape_txt.text = "all";
						}
						
						if (_main.skinUndertone_txt)
						{
							_main.skinUndertone_txt.text = "all";
						}
					}
				}
				
			}
			
			var numberOfProducts:int = productArray.length;
			
			_numberOfInvalidThumbnailFilenames = 0;
			
			var firstIteration:Boolean = true;
			
			for (var i:int=0; i<numberOfProducts; i++)
			{
				if (productArray[i].thumbnailFilename == "" ||  _recommendedProductViewIdsArray.indexOf(productArray[i].colorArray[0].productViewId) == -1)
				{
					_numberOfInvalidThumbnailFilenames += 1;
				} else {
					_main.recommendedProducts_txt.text += productArray[i].productManufacturer + " : " + productArray[i].productModel + "\n";					
				}				
			}
		}
		
		public function clearRealtimeProfileValues():void
		{
			if(_config.banner_info.has_recommendations == true)
			{
				if (_main.gender_txt != null)
				{
					_main.gender_txt.text = "";
				}
				
				if (_main.faceShape_txt != null)
				{
					_main.faceShape_txt.text = "";
				}
				
				if (_main.skinUndertone_txt != null)
				{
					_main.skinUndertone_txt.text = "";
				}
				
				if (_main.recommendedProducts_txt != null)
				{
					_main.recommendedProducts_txt.text = "";
				}
			}
		}

		override public function adjustPhotoPosition():void
		{			
			hideUndetectedFeaturesView();
			
			super.adjustPhotoPosition();
		}
		
		override public function uploadNewPhoto():void
		{			
			hideUndetectedFeaturesView();
			hideTryOnViewForSelectPhotoSourceView();	
			
			super.uploadNewPhoto();
		}
		
		override public function cancelUploadPhoto():void
		{			
			hideUndetectedFeaturesView();
			hideTryOnViewForSelectPhotoSourceView();	
			
			super.cancelUploadPhoto();
		}
		
		override public function restorePriorPositionedPhoto():void
		{
			super.restorePriorPositionedPhoto();
		}
		
		public function launchRealtimeTryOnTracking():void
		{			
			var realtimeTryOnURL:String;
			
			realtimeTryOnURL = _config.select_photo_source_view.real_time_try_on_url;			
			
			var urlRequest:URLRequest = new URLRequest(realtimeTryOnURL);
			
			if (urlRequest.url.indexOf("www.") == 0)
			{
				urlRequest.url = "http://" + urlRequest.url;
			}
			
			if (!main.isSWFRunningLocally)
			{
				if (_config.banner_info.has_doubleclick_tracking == "true")
				{
					main.enabler.exit("RealtimeTryOn_URL", urlRequest.url);
				} else {
					navigateToURL(urlRequest, "_top");
				}
			} else {
				navigateToURL(urlRequest, "_top");
			}
		}
		
		public function getProductViewIdFromMouseEvent(event:MouseEvent):String
		{
			_lastItemClickedOnProductViewId = _productArray[event.currentTarget.index].colorArray[0].productViewId.toString();
			
			return _lastItemClickedOnProductViewId;
		}
		
		public function getProductViewIdFromTransformEvent(event:TransformEvent):String
		{			
			var currentItem:TransformItem = (event.currentTarget as TransformItem);
			
			_lastItemClickedOnProductViewId = MovieClip(currentItem.targetObject).productViewId;
			
			return _lastItemClickedOnProductViewId;
		}
		
		override public function showSelectPhotoSourceView():void
		{
			super.showSelectPhotoSourceView();
			
			hideTryOnViewForSelectPhotoSourceView();
		}		
		
		public function showAdjustRecognitionResultView():void
		{
			if (super.main.adjustRecognitionResultView != null)
			{
				transitionInAdjustRecognitionResultView();
			} else {
				super.main.createAdjustRecognitionResultView();
			}
		}
		
		public function showUndetectedFeaturesView():void
		{
			if (super.main.undetectedFeaturesView != null)
			{
				transitionInUndetectedFeaturesView();
			} else {
				super.main.createUndetectedFeaturesView();
			}
		}
		
		public function hideTryOnViewForSelectPhotoSourceView():void
		{
			transitionOutTryOnViewForSelectPhotoSourceView();
		}
		
		public function hideUndetectedFeaturesView():void
		{
			transitionOutUndetectedFeaturesView();
		}
		
		public function hideAdjustRecognitionResultView():void
		{
			transitionOutAdjustRecognitionResultView();
		}
		
		override public function hideAllViews():void
		{	
			transitionOutTryOnViewForSelectPhotoSourceView();
			
			transitionOutUploadFromWebcamView();
			
			transitionOutAdjustRecognitionResultView();
			
			transitionOutUndetectedFeaturesView();
			
			super.hideAllViews();
		}
				
		/////////////////////////////////////////////////////////// TRANSITION METHODS ///////////////////////////////////////////////////////////
		
		public function transitionOutTryOnViewForSelectPhotoSourceView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_TRYON_VIEW_FOR_SELECT_PHOTO_VIEW));
		}				
		
		public function transitionInAdjustRecognitionResultView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_ADJUST_RECOGNITION_RESULT_VIEW));
		}
		
		public function transitionOutAdjustRecognitionResultView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_ADJUST_RECOGNITION_RESULT_VIEW));
		}
		
		public function transitionInUndetectedFeaturesView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_IN_UNDETECTED_FEATURES_VIEW));
		}	
		
		public function transitionOutUndetectedFeaturesView():void
		{
			dispatchEvent(new Event(TransitionEvent.TRANSITION_OUT_UNDETECTED_FEATURES_VIEW));
		}
		
		override protected function updateData () : void
		{			
			trace("TryOnModel Updated");
			
			super.updateData();			
		}

		public function get setupProducts():Boolean
		{
			return _setupProducts;
		}

		public function set setupProducts(value:Boolean):void
		{
			_setupProducts = value;
		}

	}
	
}