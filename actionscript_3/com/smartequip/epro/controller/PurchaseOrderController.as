/**
 * 
 * @author Lorin Wiener
 * @copyright SmartEquip, Inc.
 * 
 * $Id$
 * $LastChangedDate$
 * $Rev$
 */

/**
 *
 * PurchaseOrderController is responsible for controlling the PurchaseOrderView that is displayed when
 * the user selects the "Purchase Order" tab in the Tabs view.  This controller also
 * initializes other controllers which control various views loaded as separate swfs
 * into the vendor order itself.  In addtion this controller also handles the save and submit process
 * for Purchase Orders.
 * 
 *
 */

import com.smartequip.core.event.EventBroadcaster;
import com.smartequip.core.controller.SEBaseController;
import com.smartequip.core.sebo.po.OrderInfoPropertyVo;
import com.smartequip.core.sebo.SERequest;
import com.smartequip.core.sebo.po.OrderDefaultRequest;
import com.smartequip.core.sebo.po.DefaultOrderOptionsVo;
import com.smartequip.core.sebo.po.SuggestedPOVo;
import com.smartequip.core.sebo.po.POItemVo;
import com.smartequip.core.sebo.po.PurchaseOrderVo;
import com.smartequip.core.sebo.po.POHeaderVo;
import com.smartequip.core.sebo.po.POHeaderOrderOptions;
import com.smartequip.core.sebo.AddressVo;
import com.smartequip.core.sebo.po.CustomerInfoVo;
import com.smartequip.core.sebo.po.OrderOptionVo;
import com.smartequip.core.sebo.po.ShippingInformationVo;
import com.smartequip.core.sebo.po.OrderDefaultResponse;
import com.smartequip.core.sebo.po.SubmitPoResponse;

/* 
  // This portion of code hidden for proprietary purposes
*/

import com.smartequip.epro.controller.advancedAssignment.OrderFormDetailController;
import com.smartequip.core.sebo.AttributeConstants;
import com.smartequip.epro.controller.po.PurchaseOrderPrintController;
import com.smartequip.core.sebo.po.PORuleVo;
import com.smartequip.core.sebo.po.CustomAttributeVo;
import com.smartequip.epro.model.cart.CartBO;
import com.smartequip.epro.model.purchaseOrder.PurchaseOrderBo;
import com.smartequip.core.sebo.cart.CartVo;
import com.smartequip.core.sebo.SEResponse;
import mx.utils.Delegate;

class com.smartequip.epro.controller.PurchaseOrderController extends SEBaseController {
	
	private var base_mc:MovieClip;
	private var appDataModel:AppDataModel;
	private var eventBroadcaster:EventBroadcaster;
	private var listener:Object;
	private var purchaseOrderInstance_mc:MovieClip;
	private var termsAndConditionsInstance_mc:MovieClip;
	private var purchaseOrderModel:PurchaseOrderModel;	
	private var suggestedPOArray:Array;
	private var suggestedPOVo:SuggestedPOVo;
	private var poItemsArray:Array;
	private var poItemVo:POItemVo;	
	private var shipToAddressController:AddressController;	
	private var dropShipAddressController:AddressController;
	private var billToAddressController:AddressController;	
	private var purchaseOrderInformation_01_Controller:PurchaseOrderInformation_01_Controller;	
	private var purchaseOrderInformation_02_Controller:PurchaseOrderInformation_02_Controller;
	private var purchaseOrderInformation_03_Controller:PurchaseOrderInformation_03_Controller;
	private var purchaseOrderInformation_04_Controller:PurchaseOrderInformation_04_Controller;	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	private var purchaseOrderSaveSuccessDialogBoxInstance_mc:MovieClip;
	private var purchaseOrderSaveSuccessDialogBoxController:PurchaseOrderSaveSuccessDialogBoxController;
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	// CONSTRUCTOR	

	public function PurchaseOrderController() {		
		init();
	}	
	
	// INITIALIZE	

	private function init():Void {
		listener = new Object();
		appDataModel = AppDataModel.getInstance();
		eventBroadcaster = EventBroadcaster.getInstance();		
		purchaseOrderModel = PurchaseOrderModel.getInstance();
		purchaseOrderVo = purchaseOrderModel.getPurchaseOrderVo();		
		suggestedPOVo = getSuggestedPOVo();		
		poHeaderVo = suggestedPOVo.getPoHeaderVo();
		customerInfoVo = poHeaderVo.getCustomerInfo();
	}	

	public function initView(target:MovieClip, __x:Number, __y:Number) {		
		if (purchaseOrderInstance_mc == undefined) {			
			base_mc = target;
			var purchaseOrderObject:Object = appDataModel.getPurchaseOrder();		
			loadView(base_mc, purchaseOrderObject.instance, purchaseOrderObject.swf, purchaseOrderObject.symbol, {_x:__x, _y:__y}, false, onPurchaseOrderLoad);			
		}
	}
	
	// MODULE CONTROLLER METHODS
	
	private function onPurchaseOrderLoad(evt:Object):Void {		
		var suggestedPOVo:SuggestedPOVo;		
		suggestedPOVo = suggestedPOArray[0];		
		purchaseOrderInstance_mc = evt.param.instance;		
		isScreenInitialized = false;
		isTermsAndConditionsAcknowledged = false;
		purchaseOrderInstance_mc.onReturnItemsToCartButtonRelease = Delegate.create(this, returnItemsToCartButtonRelease);
		purchaseOrderInstance_mc.onCommentsButtonRelease = Delegate.create(this, commentsButtonRelease);
		purchaseOrderInstance_mc.onModifyOrderButtonRelease = Delegate.create(this, modifyOrderButtonRelease);
		purchaseOrderInstance_mc.onVerifyButtonRelease = Delegate.create(this, verifyButtonRelease);
		purchaseOrderInstance_mc.onPrintButtonRelease = Delegate.create(this, printButtonRelease);
		purchaseOrderInstance_mc.onSaveButtonRelease = Delegate.create(this, saveButtonRelease);
		purchaseOrderInstance_mc.onSubmitButtonRelease = Delegate.create(this, submitButtonRelease);
		purchaseOrderInstance_mc.onCloseButtonRelease = Delegate.create(this, closeButtonRelease);
		/* 
	  		// This portion of code hidden for proprietary purposes
		*/		
		purchaseOrderInstance_mc.setMaxChars("PurchaseOrderBackground_mc.PurchaseOrderComments_mc.PurchaseOrderComments_txt", 255);		
		purchaseOrderInstance_mc.toggleWordWrap("PurchaseOrderBackground_mc.PurchaseOrderComments_mc.PurchaseOrderComments_txt", true);		
		purchaseOrderInstance_mc.togglePurchaseOrderCommentsVisibility();		
		if (isPopulatePurchaseOrderSelectorComboBox == true) {		
			populatePurchaseOrderSelectorComboBox();			
		}			
		createAddressInstances();			
		createPurchaseOrderItemListInstance();			
		createPurchaseOrderInformationInstances();		
		loadPurchaseOrderDefaults(suggestedPOVo, false, "");	
	}	
	
	// DELEGATES
	
	private function returnItemsToCartButtonRelease():Void {
		resetPOCommentsVisibility();				
		purchaseOrderItemListController.resetOrderItemListVisibility();		
		onReturnItemsToCartButtonRelease();
		GlobalMessageController.setMessage("");		
	}	
	
	private function commentsButtonRelease():Void {	
		onCommentsButtonRelease();
		GlobalMessageController.setMessage("");			
	}	
	
	private function modifyOrderButtonRelease():Void {
		onModifyOrderButtonRelease();
		GlobalMessageController.setMessage("");		
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	private function verifyButtonRelease():Void {			
		resetPOCommentsVisibility();				
		purchaseOrderItemListController.resetOrderItemListVisibility();		
		onVerifyButtonRelease();
		GlobalMessageController.setMessage("");			
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	private function submitButtonRelease():Void {		
		resetPOCommentsVisibility();				
		purchaseOrderItemListController.resetOrderItemListVisibility();		
		onSubmitButtonRelease();	
	}
	
	private function closeButtonRelease():Void {		
		onCloseButtonRelease();	
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/	
	
	// CREATE SWF INSTANCES	
	
	private function createAddressInstances():Void {	
		var shipToAddressObject:Object = appDataModel.getAddress();	
		var dropShipAddressObject:Object = appDataModel.getAddress();	
		var billToAddressObject:Object = appDataModel.getAddress();			
		shipToAddressController = new AddressController();		
		dropShipAddressController = new AddressController();		
		billToAddressController = new AddressController();		
		shipToAddressController.initView(purchaseOrderInstance_mc.getAddressesContainer(), 0.0, 0.0, "shipTo" + shipToAddressObject.instance);		
		dropShipAddressController.initView(purchaseOrderInstance_mc.getAddressesContainer(), 183.0, 0.0, "dropShip" + dropShipAddressObject.instance);		
		billToAddressController.initView(purchaseOrderInstance_mc.getAddressesContainer(), 366.0, 0.0, "billTo" + billToAddressObject.instance);		
		shipToAddressController.onOpenSelectLocationDialogBox = Delegate.create(this, openSelectLocationDialogBox);		
		shipToAddressController.onAddressFieldChanged = Delegate.create(this, addressFieldChanged);		
		dropShipAddressController.onAddressFieldChanged = Delegate.create(this, addressFieldChanged);		
		billToAddressController.onAddressFieldChanged = Delegate.create(this, addressFieldChanged);		
		configureAddressFields(shipToAddressController, true, false, false, false, true, false, true, true, false, false, false, false, false, false, false, false);		
		configureAddressFields(dropShipAddressController, false, true, false, false, false, true, false, false, true, true, true, true, true, true, true, true);		
		configureAddressFields(billToAddressController, false, false, true, true, false, false, false, true, false, false, false, false, false, false, false, false);		
	}
	
	private function createPurchaseOrderInformationInstances():Void {	
		var purchaseOrderInformation_01_Object:Object = appDataModel.getPurchaseOrderInformation_01();	
		var purchaseOrderInformation_02_Object:Object = appDataModel.getPurchaseOrderInformation_02();	
		var purchaseOrderInformation_03_Object:Object = appDataModel.getPurchaseOrderInformation_03();	
		var purchaseOrderInformation_04_Object:Object = appDataModel.getPurchaseOrderInformation_04();	
		var purchaseOrderInformation_05_Object:Object = appDataModel.getPurchaseOrderInformation_05();
		purchaseOrderInformation_01_Controller = new PurchaseOrderInformation_01_Controller();		
		purchaseOrderInformation_03_Controller = new PurchaseOrderInformation_03_Controller();		
		purchaseOrderInformation_04_Controller = new PurchaseOrderInformation_04_Controller();		
		purchaseOrderInformation_05_Controller = new PurchaseOrderInformation_05_Controller();	
		purchaseOrderInformation_02_Controller = new PurchaseOrderInformation_02_Controller();
		purchaseOrderInformation_01_Controller.initView(purchaseOrderInstance_mc.getOrderInformationContainer(), 4.0, 3.0, purchaseOrderInformation_01_Object.instance);
		purchaseOrderInformation_05_Controller.onEdit = Delegate.create(this, purchaseOrderInformation_05_Controller_onEdit);
		purchaseOrderInformation_05_Controller.onDataSet = Delegate.create(this, purchaseOrderInformation_05_Controller_onDataSet);
		purchaseOrderInformation_04_Controller.onOpenPurchaseOrderShippingOptionsDialogBox = Delegate.create(this, openPurchaseOrderShippingOptionsDialogBox);
		purchaseOrderInformation_02_Controller.onOrderTypeChangeOrderDefaults = Delegate.create(this, purchaseOrderInformation_02_Controller_onOrderTypeChangeOrderDefaults);
		purchaseOrderInformation_02_Controller.onOpenPurchaseOrderUpdatePricesDialogBox = Delegate.create(this, onOpenPurchaseOrderUpdatePricesDialogBox);
		purchaseOrderInformation_02_Controller.onDateChanged = Delegate.create(this, onDateChanged);
		purchaseOrderInformation_02_Controller.onSetDefaultEmailAddress = Delegate.create(this, onSetDefaultEmailAddress);
		purchaseOrderInformation_01_Controller.onSetDefaultPOPhoneNumber = Delegate.create(this, onSetDefaultPOPhoneNumber);
	}
	
	private function createPurchaseOrderItemListInstance():Void {	
		var purchaseOrderItemListObject:Object = appDataModel.getPurchaseOrderItemList();		
		suggestedPOVo = getSuggestedPOVo();		
		purchaseOrderItemListController = new PurchaseOrderItemListController();		
		purchaseOrderItemListController.initView(purchaseOrderInstance_mc.getItemsContainer(), 17.5, 0, purchaseOrderItemListObject.instance);		
		purchaseOrderItemListController.onItemRelease = Delegate.create( this, purchaseOrderItemListController_onItemRelease);		
		purchaseOrderItemListController.onPopulateTotalField = Delegate.create(this, populateTotalField);
	}
	
	// CONFIGURE PURCHASE ORDER
	
	private function configureAddressFields(controllerInstance:AddressController, shipToTitleVisiblity:Boolean, dropShipTitleVisibility:Boolean, billToTitleVisibility:Boolean,
		requisitionLocVisibility:Boolean, addressFieldTitlesVisibility:Boolean, addressInstructionsVisibility:Boolean, selectLocationVisibility:Boolean, locationFieldVisibility:Boolean,
		locationEditable:Boolean, nameEditable:Boolean, address1Editable:Boolean, address2Editable:Boolean, cityEditable:Boolean, stateEditable:Boolean, zipCodeEditable:Boolean,
		phoneEditable:Boolean):Void {		
		controllerInstance.toggleShipToTitleVisibility(shipToTitleVisiblity);
		controllerInstance.toggleDropShipTitleVisibility(dropShipTitleVisibility);
		controllerInstance.toggleBillToTitleVisibility(billToTitleVisibility);
		controllerInstance.toggleRequisitionLocVisibility(requisitionLocVisibility);
		controllerInstance.toggleAddressFieldTitlesVisibility(addressFieldTitlesVisibility);
		/* 
	  		// This portion of code hidden for proprietary purposes
		*/
	}
	
	private function configurePurchaseOrder():Void {
		purchaseOrderInstance_mc.configurePurchaseOrder(suggestedPOVo);
		purchaseOrderInformation_01_Controller.configureFields(poHeaderOrderOptions);
		purchaseOrderInformation_02_Controller.configureFields(poHeaderOrderOptions);
		purchaseOrderInformation_03_Controller.configureFields(poHeaderOrderOptions);
		purchaseOrderInformation_04_Controller.configureFields(poHeaderOrderOptions);
		purchaseOrderInformation_05_Controller.configureFields(poHeaderOrderOptions);
		purchaseOrderItemListController.configureFields(poHeaderOrderOptions);
	}
	
	// POPULATE METHODS	
	
	private function populatePurchaseOrderSelectorComboBox():Void {		
		if (purchaseOrderInstance_mc == undefined) {			
			isPopulatePurchaseOrderSelectorComboBox = true;			
		} else {			
			purchaseOrderInstance_mc.populatePurchaseOrderSelectorComboBox(suggestedPOArray);			
			isPopulatePurchaseOrderSelectorComboBox = false;			
		}		
	}	
	
	private function populatePurchaseOrderFields(suggestedPOArray:Array, purchaseOrderVo:PurchaseOrderVo, customerInfoVo:CustomerInfoVo, poHeaderVo:POHeaderVo):Void {
		purchaseOrderInstance_mc.populatePurchaseOrderFields(suggestedPOArray, purchaseOrderVo, customerInfoVo, poHeaderVo);
		purchaseOrderInstance_mc.toggleSubmitButtonEnabled(LegacyBridge.getSubmitPoFlag());		
	}	
	
	private function populateAddressFields():Void {		
		var shipToAddressVo:AddressVo;			
		var billToAddressVo:AddressVo;			
		var dropShipAddressVo:AddressVo;
		var dropShipEnabled:Boolean;
		var isDropShipAddressExists:Boolean; // VARIABLE TO TRACK WHETHER AN ADDRESS ALREADY EXISTS IN THE DROP SHIP ADDRESS VIEW		
		suggestedPOVo = getSuggestedPOVo();		
		poHeaderOrderOptions = suggestedPOVo.getPoHeaderOrderOptions();		
		dropShipEnabled = poHeaderOrderOptions.getDropShipEnabled();
		dropShipAddressController.toggleDropShipVisibility(dropShipEnabled);		
		shipToAddressController.configureFields(poHeaderOrderOptions, poHeaderOrderOptions.getIsSelectLocationVisible() == true);
		dropShipAddressController.configureFields(poHeaderOrderOptions, false);
		billToAddressController.configureFields(poHeaderOrderOptions, false);
		isDropShipAddressExists = false;		
		for (var i = 0; i < addressArray.length; i++ )  {					
			var addressVo:AddressVo = addressArray[i];				
			if (addressVo.getType() == AddressVo.SHIPTOCODE) {				
				shipToAddressVo = addressArray[i];				
				shipToAddressController.populateAddressFields(shipToAddressVo);				
			}			
			if (addressVo.getType() == AddressVo.DROPSHIPCODE) {				
				isDropShipAddressExists = true;				
				dropShipAddressVo = addressArray[i];					
				dropShipAddressController.populateAddressFields(dropShipAddressVo);					
			}			
			if (addressVo.getType() == AddressVo.BILLTOCODE) {				
				billToAddressVo = addressArray[i];				
				billToAddressController.populateAddressFields(billToAddressVo);				
			}				
		}
		
		/* 
		  // This portion of code hidden for proprietary purposes
		*/
		
		if (dropShipEnabled == true && isDropShipAddressExists == false) {			
			addressArray.push(dropShipAddressVo);			
			dropShipAddressController.populateAddressFields(dropShipAddressVo);	
			dropShipAddressController.onAddressStateSetFocus = Delegate.create(this, onAddressStateSetFocus);
			dropShipAddressController.onAddressStateKillFocus = Delegate.create(this, onAddressStateKillFocus);
		} else if (dropShipEnabled == true && isDropShipAddressExists == true) {
			dropShipAddressController.onAddressStateSetFocus = Delegate.create(this, onAddressStateSetFocus);
			dropShipAddressController.onAddressStateKillFocus = Delegate.create(this, onAddressStateKillFocus);
		} else if (dropShipEnabled == false && isDropShipAddressExists == false) {
			dropShipAddressController.populateAddressFields(dropShipAddressVo);						
			dropShipAddressController.onAddressStateSetFocus = undefined;
			dropShipAddressController.onAddressStateKillFocus = undefined;
		}
	}	
	
	private function populatePurchaseOrderInformationFields():Void {
		purchaseOrderInformation_01_Controller.populatePurchaseOrderInformation_01_Fields(poHeaderVo, poHeaderOrderOptions.getOrderOptionList());		
		purchaseOrderInformation_02_Controller.populatePurchaseOrderInformation_02_Fields(poHeaderVo, poHeaderOrderOptions.getOrderOptionList(), poHeaderOrderOptions.getDefaultOrderOptionsVo(), poHeaderOrderOptions.getParcelShipping());
		switch (poHeaderOrderOptions.getOrderInfoPropertyVo().getShippingOptionConfig()) {			
			case "3" :			
				purchaseOrderInformation_03_Controller.populatePurchaseOrderInformation_03_Fields(poHeaderVo, poHeaderOrderOptions.getDefaultOrderOptionsVo(), poHeaderOrderOptions.getOrderOptionList());
				break;
			case "4" :			
				purchaseOrderInformation_04_Controller.populatePurchaseOrderInformation_04_Fields(poHeaderVo, poHeaderOrderOptions.getDefaultOrderOptionsVo(), poHeaderOrderOptions.getOrderOptionList(), poHeaderOrderOptions.getParcelShipping(), poHeaderOrderOptions.getFreightShipping());	
				break;
			case "5" :
				purchaseOrderInformation_05_Controller.populatePurchaseOrderInformation_05_Fields(poHeaderVo, poHeaderOrderOptions.getOrderOptionList());
				break;
			default :			
				purchaseOrderInformation_03_Controller.populatePurchaseOrderInformation_03_Fields(poHeaderVo, poHeaderOrderOptions.getDefaultOrderOptionsVo(), poHeaderOrderOptions.getOrderOptionList());
				break;			 
		}
	}	
	
	private function populateParcelFreightFields():Void {		
		purchaseOrderInformation_04_Controller.populatePurchaseOrderInformation_04_Fields(poHeaderVo, poHeaderOrderOptions.getDefaultOrderOptionsVo(), null, poHeaderOrderOptions.getParcelShipping(), poHeaderOrderOptions.getFreightShipping());
	}	
	
	private function populatePurchaseOrderItems():Void {		
		var suggestedPOVo:SuggestedPOVo = getSuggestedPOVo();
		purchaseOrderItemListController.populatePurchaseOrderItems(suggestedPOVo, poHeaderVo);
	}	
	
	private function populateTotalField() {		
		purchaseOrderInstance_mc.populateTotalField();		
	}	
	
	// OPEN DIALOG METHODS	
	
	private function openPurchaseOrderShippingOptionsDialogBox():Void {		
		onOpenPurchaseOrderShippingOptionsDialogBox();		
	}
	
	private function openSavePurchaseOrderDialogBox():Void {
		var purchaseOrderSaveDialogBoxObject:Object = appDataModel.getPurchaseOrderSaveDialogBox();
		purchaseOrderSaveDialogBoxSwf = purchaseOrderSaveDialogBoxObject.swf;
		purchaseOrderSaveDialogBoxSymbol = purchaseOrderSaveDialogBoxObject.symbol;
		purchaseOrderSaveDialogBoxInstance = purchaseOrderSaveDialogBoxObject.instance;		
		listener.purchaseOrderSaveDialogBox = eventBroadcaster.receiveEvent(this, EventBroadcastConst.SWFREADY, onPurchaseOrderSaveDialogBoxLoad, purchaseOrderSaveDialogBoxSwf, purchaseOrderSaveDialogBoxInstance);
		purchaseOrderSaveDialogBoxController = new PurchaseOrderSaveDialogBoxController();
		purchaseOrderSaveDialogBoxController.initView(purchaseOrderInstance_mc, 271.0, 211.6);
		purchaseOrderSaveDialogBoxController.onSavePurchaseOrder = Delegate.create(this, onSavePurchaseOrder);
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	private function openSaveSuccessPurchaseOrderDialogBox():Void {
		purchaseOrderSaveSuccessDialogBoxObject = appDataModel.getPurchaseOrderSaveSuccessDialogBox();
		purchaseOrderSaveSuccessDialogBoxSwf = purchaseOrderSaveSuccessDialogBoxObject.swf;
		purchaseOrderSaveSuccessDialogBoxSymbol = purchaseOrderSaveSuccessDialogBoxObject.symbol;
		purchaseOrderSaveSuccessDialogBoxInstance = purchaseOrderSaveSuccessDialogBoxObject.instance;
		listener.purchaseOrderSaveSuccessDialogBox = eventBroadcaster.receiveEvent(this, EventBroadcastConst.SWFREADY, onPurchaseOrderSaveSuccessDialogBoxLoad, purchaseOrderSaveSuccessDialogBoxSwf, purchaseOrderSaveSuccessDialogBoxInstance);
		purchaseOrderSaveSuccessDialogBoxController = new PurchaseOrderSaveSuccessDialogBoxController();
		purchaseOrderSaveSuccessDialogBoxController.initView(purchaseOrderInstance_mc, 271.0, 211.6);
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	private function openErrorDialogBox(callbackHandler:Function):Void {
		if(errorDialogBoxController == undefined){
			errorDialogBoxController = new ErrorDialogBoxController();
		}
		errorDialogBoxController.onErrorDialogBoxLoaded = Delegate.create(this, callbackHandler);
		errorDialogBoxController.initView(base_mc, 271.0, 211.6);
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	public function closeSaveSuccessDialogBox() {		
		purchaseOrderSaveSuccessDialogBoxInstance_mc.closeButtonRelease();
	}	
	
	public function closeSubmitSuccessDialogBox() {		
		purchaseOrderSubmitSuccessDialogBoxInstance_mc.closeButtonRelease();
	}	
	
	// DELEGATE HANDLERS	
	
	private function onReturnItemsToCartButtonRelease() {	
		var currentSuggestedPOVo:SuggestedPOVo;		
		currentSuggestedPOVo = getSuggestedPOVo();		
		onReturnToCart(currentSuggestedPOVo);			
	}	
	
	private function onNextOrderFromSaveSuccessDialogButtonRelease() {		
		closeSaveSuccessDialogBox();		
		nextOrder();		
	}	
	
	private function onReturnToCartFromSaveSuccessDialogButtonRelease() {	
		closeSubmitSuccessDialogBox();		
		nextOrder();		
		onReturnToCart();			
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	private function onVerifyButtonRelease():Void {
		var curMfrID:String;
		var orderType:String;
		var shipVia:String;
		var shipViaString:String;
		var shipViaArray:Array;
		var freightTerms:String;
		var carrierAccountNumber:String;
		var lastVerifyCode:String;
		var shippingOption:OrderOptionVo;		
		curMfrID = suggestedPOVo.getManufacturerID();		
		orderType = poHeaderVo.getOrderTypePartnerNumber();		
		shippingOption = poHeaderVo.getShippingOption();		
		shipViaString = shippingOption.getOptionDescription();		
		shipViaArray = shipViaString.split(":");		
		shipVia = shipViaArray[0];		
		freightTerms = poHeaderVo.getFreightTermsPartnerNumber();		
		carrierAccountNumber = poHeaderVo.getCarrierAccountNumber();		
		lastVerifyCode = purchaseOrderModel.getLastVerifyCode();
		if (lastVerifyCode == undefined) {			
			lastVerifyCode = "";			
			purchaseOrderModel.setLastVerifyCode("");			
		}		
		purchaseOrderModel.verifyOrderOptions(curMfrID, orderType, shipVia, freightTerms, carrierAccountNumber, lastVerifyCode);
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/	
	
	private function onSaveButtonRelease():Void {
		if (LegacyBridge.getIsSaveConfirmationDialogRequired() == true) {
			openSavePurchaseOrderDialogBox();	
		} else {
			savePurchaseOrder();
		}
	}	
	
	private function onSubmitButtonRelease():Void {
		if (LegacyBridge.getIsSubmitConfirmationDialogRequired() == true) {
			openSubmitPurchaseOrderDialogBox();
		} else {
			submitPurchaseOrder();
		}
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/	
	
	private function onSavePurchaseOrder():Void {
		var suggestedPOVo:SuggestedPOVo;
		suggestedPOVo = getSuggestedPOVo();			
		poItemsArray = suggestedPOVo.getPoItems();
		PurchaseOrderBo.createPurchaseOrderVo(suggestedPOVo, purchaseOrderVo, poHeaderVo, poItemsArray, purchaseOrderModel);			
		purchaseOrderVo = purchaseOrderModel.getPurchaseOrderVo();
		purchaseOrderVo.setOKStatus("2");
		purchaseOrderVo.setStatusID("2");
		purchaseOrderVo.setSubmit("2");			
		purchaseOrderModel.submitPurchaseOrder();			
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	private function onInvalidEmailErrorDialogBoxLoad(evt:Object):Void {
		errorDialogBoxController.setCopy("Invalid Email Address", "The format of the email address entered is invalid.", "", "");				
	}	
	
	private function onInvalidRequiredFieldsErrorDialogBoxLoad(evt:Object):Void {
		errorDialogBoxController.setCopy("Required Fields Warning", "One or more required fields indicated by an orange title have not been filled in.", "", "");				
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/

	private function onPurchaseOrderDefaultsReply():Void {
		var status:String;
		var messageBoxMessage:String;
		var tempPoHeaderVo:POHeaderVo;
		status = purchaseOrderDefaultResponseObject.getStatus();
		messageBoxMessage = purchaseOrderDefaultResponseObject.getMessage();
		suggestedPOVo = getSuggestedPOVo();
		switch (status) {			
			case "0" :			
				GlobalMessageController.setMessage(messageBoxMessage);
				break;				
			default :
				if (suggestedPOVo.getPoHeaderVo() == null) {		
					tempPoHeaderVo = purchaseOrderModel.getPOHeaderVo();			
					suggestedPOVo.setPoHeaderVo(tempPoHeaderVo);
					// BLANK OUT DROP SHIP ADDRESS FOR NEW ORDERS ONLY PER REQUIREMENTS
					blankOutDropShipAddress();
				} else {			
					customerInfoVo = suggestedPOVo.getPoHeaderVo().getCustomerInfo();		
					customerInfoVo.setDiscountList(purchaseOrderModel.getPOHeaderVo().getCustomerInfo().getDiscountList());	
				}
				if (suggestedPOVo.getPoHeaderVo().getPhone().length == 0) {
					suggestedPOVo.getPoHeaderVo().setPhone(LegacyBridge.getPhone());
				}
				if (suggestedPOVo.getPoHeaderVo().getEmail().length == 0) {
					suggestedPOVo.getPoHeaderVo().setEmail(LegacyBridge.getEmail());
				}
				poHeaderVo = suggestedPOVo.getPoHeaderVo();
				customerInfoVo = poHeaderVo.getCustomerInfo();
				addressArray = customerInfoVo.getAddressList();
				discountArray = customerInfoVo.getDiscountList();
				if (suggestedPOVo.getPoHeaderOrderOptions() == null or poHeaderVo.getIsOrderDefaultsCalled() == false) {			
					poHeaderOrderOptions = purchaseOrderModel.getPOHeaderOrderOptions();			
					suggestedPOVo.setPoHeaderOrderOptions(poHeaderOrderOptions);				
				}		
				poHeaderVo.setIsOrderDefaultsCalled(true);
				poHeaderOrderOptions = suggestedPOVo.getPoHeaderOrderOptions();
				purchaseOrderItemListController.setOrderOptionsArray(poHeaderOrderOptions.getOrderOptionList());		
				toggleParcelFreightVisibility();
				configurePurchaseOrder(suggestedPOVo);
				populatePurchaseOrderFields(suggestedPOArray, purchaseOrderVo, customerInfoVo, poHeaderVo);
				populateAddressFields();		
				populatePurchaseOrderInformationFields();		
				populatePurchaseOrderItems();		
				isScreenInitialized = true;
				break;			 
		}
		PurchaseOrderBo.createTabIndices(purchaseOrderInstance_mc, shipToAddressController, dropShipAddressController, billToAddressController);
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	public function loadOrderStatus():Void {
		onLoadOrderStatus();
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	private function onDateChanged(evt:Object) {
		var poItemsArray:Array = suggestedPOVo.getPoItems();

		for (var i:Number = 0; i < poItemsArray.length; i++) {
			if (poItemsArray[i].getShipDateRangeStart().length > 0) {
				if (evt.target.selectedDate.valueOf() >= Utils.formatToDate(poItemsArray[i].getShipDateRangeStart()).valueOf()) {
					poItemsArray[i].setShipDate(Utils.formatFromDate(evt.target.selectedDate));
				} else {
					poItemsArray[i].setShipDate(poItemsArray[i].getShipDateRangeStart());
				}
				// ACCOUNT FOR DATE FIELD COMPONENT PROBLEM THAT OCCURS WHEN USER SELECTS ALREADY SELECTED DATE ON DATE COMPONENT CAUSING DATE FIELD TO DISPLAY BLANK
				if (poItemsArray[i].getShipDate().indexOf("undefined") != -1) {
					poItemsArray[i].setShipDate("");
				}
			}
		}
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	// PO METHODS
	
	private function loadPurchaseOrderDefaults(suggestedPOVo:SuggestedPOVo, isNeedShippingOptionsUpdatedMessage:Boolean, shippingState:String):Void {				
		var orderDefaultRequest:OrderDefaultRequest;
		var defaultOrderOptionsVo:DefaultOrderOptionsVo;
		var isOrderContainsOversizedItem:Boolean = false;
		var tempPoRule:PORuleVo = new PORuleVo();
		var rulesArray:Array = new Array();
		orderDefaultRequest = new OrderDefaultRequest();		
		orderDefaultRequest.setManufacturerId(suggestedPOVo.getManufacturerID());		
		orderDefaultRequest.setOrderType(suggestedPOVo.getOrderType());		
		orderDefaultRequest.setSourceVo(suggestedPOVo.getSourceVo());		
		if (suggestedPOVo.getCurrency() != null){
			orderDefaultRequest.setCurrency(suggestedPOVo.getCurrency());
		} else if (purchaseOrderModel.getPurchaseOrderVo().getPurchaseOrderHeader().getCurrency()!= null) {
			orderDefaultRequest.setCurrency(purchaseOrderModel.getPurchaseOrderVo().getPurchaseOrderHeader().getCurrency());
		}
		orderDefaultRequest.setOrderOptionsUpdate(isNeedShippingOptionsUpdatedMessage);
		orderDefaultRequest.setOrderTypePartnerNumber(isNeedShippingOptionsUpdatedMessage ? purchaseOrderInformation_02_Controller.getOrderTypeComboBox() : "");
		for (var i = 0; i < suggestedPOVo.getPoItems().length; i++) {
			var poItemVo:POItemVo = suggestedPOVo.getPoItems()[i];
			if (poItemVo.getAttributeList()[0].getType() == AttributeConstants.ITEM_OVERSIZED) {
				isOrderContainsOversizedItem = true;
			}
		}
		orderDefaultRequest.setIsOversized(isOrderContainsOversizedItem);
		orderDefaultRequest.setShipToState(shippingState);
		purchaseOrderModel.setOrderDefaultsRequestShippingState(shippingState);
		if (suggestedPOVo.getRuleOrderTypeDesc()!= null) {
			tempPoRule.setOrderTypeDesc(suggestedPOVo.getRuleOrderTypeDesc());
			rulesArray.push(tempPoRule);
		} else if (purchaseOrderModel.getPurchaseOrderVo().getRuleOrderTypeDesc() != null ) {
			tempPoRule.setOrderTypeDesc(purchaseOrderModel.getPurchaseOrderVo().getRuleOrderTypeDesc());			
			rulesArray.push(tempPoRule);
		}		
		orderDefaultRequest.setRuleList(rulesArray);		
		defaultOrderOptionsVo = PurchaseOrderBo.createDefaultOrderOptionsVo(suggestedPOVo);
		if (defaultOrderOptionsVo != null) {	
			orderDefaultRequest.setDefaultOrderOptionsVo(defaultOrderOptionsVo);		
		}
		purchaseOrderModel.loadPurchaseOrderDefaults(orderDefaultRequest);
	}
	
	private function purchaseOrderDefaultsReply(purchaseOrderDefaultResponseObject:OrderDefaultResponse):Void {
		this.purchaseOrderDefaultResponseObject = purchaseOrderDefaultResponseObject;
		onPurchaseOrderDefaultsReply();		
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/	
	
	private function submitPurchaseOrder():Void {
		if (validatePO()) {
			if (isDisplayPoHeaderMessage && poHeaderVo.getMessage() != null && poHeaderVo.getMessage() != "") {
				isDisplayPoHeaderMessage = false;
				purchaseOrderSubmitDialogBoxController.closeButtonRelease();
				openSubmitPurchaseOrderDialogBox(onOrderTypeCompleteWarning);
			} else if (poHeaderOrderOptions.getOrderInfoPropertyVo().getHasTermsAndConditions() == true and isTermsAndConditionsAcknowledged == false) {
				openTermsAndConditionsDialogBox();
			} else {
				onSubmitPurchaseOrder();		
			}
		}
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	// SETTERS AND GETTERS	
	
	public function setSuggestedPOArray(argSuggestedPOArray:Array, isLoadingSaved:Boolean):Void {
		var newOrderSEReferenceNumber:String = argSuggestedPOArray[0].getSEReferenceNumber();
		if (isDuplicateOrder(newOrderSEReferenceNumber) == true) {
			openErrorDialogBox(onOpenDuplicateOrderErrorDialogBoxLoad);
			return;		
		}	
		if (this.suggestedPOArray == undefined) {			
			this.suggestedPOArray = new Array();			
		}
		if (argSuggestedPOArray.length > 0) {
			this.suggestedPOArray = this.suggestedPOArray.concat(argSuggestedPOArray);		
		}		
		purchaseOrderModel.setSuggestedPOArray(this.suggestedPOArray, isLoadingSaved, argSuggestedPOArray);		
		populatePurchaseOrderSelectorComboBox();			
		refreshPurchaseOrder();		
	}	
	
	public function getSuggestedPOArray():Array {		
		return suggestedPOArray;		
	}	
	
	public function getSuggestedPOVo():SuggestedPOVo {		
		var suggestedPOVo:SuggestedPOVo;		
		suggestedPOVo = purchaseOrderInstance_mc.getSuggestedPOVo();		
		return suggestedPOVo;		
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
}