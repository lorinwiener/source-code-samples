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
 * PurchaseOrderModel is responsible for handling the data of the Purchase Order when the user selects
 * the "Purchase Order" tab in the Tabs view.
 * 
 *
 */
 
import com.smartequip.core.event.EventBroadcaster;
import com.smartequip.core.model.SEBaseModel;
import com.smartequip.epro.data.EventBroadcastConst;
import com.smartequip.epro.data.ServiceNameConst;
import com.smartequip.epro.data.AdapterConst;
import com.smartequip.core.sebo.SEResponse;
import com.smartequip.core.sebo.AddressVo;
import com.smartequip.core.sebo.po.POHeaderVo;
import com.smartequip.core.sebo.po.POHeaderOrderOptions;
import com.smartequip.core.sebo.po.PurchaseOrderVo;
import com.smartequip.core.sebo.po.OrderDefaultResponse;
import com.smartequip.core.sebo.po.POItemVo;
import com.smartequip.core.sebo.po.CustomAttributeVo;
import com.smartequip.core.sebo.po.SubmitPoResponse;
import com.smartequip.core.sebo.po.SuggestedPOVo;
import com.smartequip.core.sebo.po.OrderOptionVo;
import com.smartequip.core.sebo.po.OrderOptionResponse;
import com.smartequip.core.sebo.po.CustomerInfoVo;
import com.smartequip.core.sebo.po.OrderDefaultRequest;
import com.smartequip.core.sebo.po.ShippingInformationVo;
import com.smartequip.core.sebo.po.ShippingOptionsVo;
import com.smartequip.core.sebo.po.ShippingPreferenceVo;
import com.smartequip.core.sebo.po.ShippingTermsVo;
import com.smartequip.core.sebo.po.DefaultOrderOptionsVo;
import com.smartequip.core.sebo.po.OrderTypeVo;
import com.smartequip.core.sebo.po.NotifyVo;
import com.smartequip.core.sebo.po.VerifyItemResponse;
import com.smartequip.core.sebo.po.VerifyOrderResponse;
import com.smartequip.core.sebo.cart.SourceVo;
import com.smartequip.sebo.CustomerDiscount;
import com.smartequip.epro.utils.GlobalMessageController;
import com.smartequip.epro.utils.Utils;
import com.smartequip.core.sebo.po.PORuleVo;
import com.smartequip.core.sebo.po.OrderInfoPropertyVo;
import com.smartequip.core.sebo.cart.CartVo;
import com.smartequip.core.sebo.po.ChangeCancelRequest;


class com.smartequip.epro.model.PurchaseOrderModel extends SEBaseModel {
	
	private var eventBroadcaster:EventBroadcaster;	
	private static var _singleton:PurchaseOrderModel = null;	
	private var purchaseOrderVo:PurchaseOrderVo;
	private var poHeaderVo:POHeaderVo;
	private var poHeaderOrderOptions:POHeaderOrderOptions;
	private var customerInfoVo:CustomerInfoVo;
	private var shipToAddressVo:AddressVo;
	private var dropShipAddressVo:AddressVo;
	private var billToAddressVo:AddressVo;
	private var purchaseOrderDefaultsResponse:OrderDefaultResponse;
	private var suggestedPOVo:SuggestedPOVo;
	private var purchaseOrderSubmitResponse:SubmitPoResponse;
	private var shippingOption:OrderOptionVo;
	private var defaultOrderOptionsVo:DefaultOrderOptionsVo;
	private var parcelShippingVo:ShippingInformationVo;
	private var freightShippingVo:ShippingInformationVo;
	private var suggestedPOArray:Array;
	private var orderOptionsList:Array;
	private var lastVerifyCode:String;
	private var createShipToEnabled:Boolean;
	private var dropShipEnabled:Boolean;
	private var isBackendCallRequiredOnStateChange:Boolean;
	private var isSelectLocationVisible:Boolean;
	private var orderInfoPropertyVo:OrderInfoPropertyVo;
	private var removeItemsArray:Array;
	private var restoredSavedOrders:Array;
	private var newOrderFormPOName:String;
	private var changeCancelRequest:ChangeCancelRequest;	
	private var abortAction:Number;
	public static var CANCEL_PO_ACTION_EDIT:Number = 1;
	private var orderDefaultsRequestShippingState:String; // VARIABLE TO CACHE THE SHIP TO OR DROP SHIP STATE THAT THE LAST ORDER DEFAULTS REPLY WAS RELATIVE TO
	
	public function PurchaseOrderModel() {		
		init();		
	}
	
	private function init() {		
		eventBroadcaster = EventBroadcaster.getInstance();		
		initTransportationClasses();		
		suggestedPOArray = new Array();
		purchaseOrderVo = new PurchaseOrderVo();		
	}
	
	public static function getInstance():PurchaseOrderModel {
		if (_singleton == null) {
			_singleton = new PurchaseOrderModel();
		}
		return _singleton;
	}
	
	private function initTransportationClasses():Void {		
		Object.registerClass("com.smartequip.sebo.CustomerDiscount", com.smartequip.sebo.CustomerDiscount);
		Object.registerClass("com.smartequip.core.sebo.SEResponse", com.smartequip.core.sebo.SEResponse);
		Object.registerClass("com.smartequip.core.sebo.AddressVo", com.smartequip.core.sebo.AddressVo);
		Object.registerClass("com.smartequip.core.sebo.po.CarrierOption", com.smartequip.core.sebo.po.CarrierOption);	
		Object.registerClass("com.smartequip.core.sebo.po.CustomerInfoVo", com.smartequip.core.sebo.po.CustomerInfoVo);
		Object.registerClass("com.smartequip.core.sebo.po.OrderDefaultResponse", com.smartequip.core.sebo.po.OrderDefaultResponse);
		Object.registerClass("com.smartequip.core.sebo.po.OrderOptionResponse", com.smartequip.core.sebo.po.OrderOptionResponse);
		/* 
	  		// This portion of code hidden for proprietary purposes
		*/
	}	
	
	// SERVICE REQUESTS	
	
	public function loadPurchaseOrderDefaults(orderDefaultRequest:OrderDefaultRequest):Void {		
		var serviceName = ServiceNameConst.ORDER_DEFAULT_SERVICE;
		var methodName = ServiceNameConst.GET_PURCHASE_ORDER_DEFAULTS_METHOD;		
		GlobalMessageController.setMessage("Retrieving order options...");		
		requestData(serviceName, methodName, this, null, AdapterConst.AMF, orderDefaultRequest);		
	}	
	
	public function verifyOrderOptions(mfrID:String, orderType:String, shipVia:String, freightTerms:String, carrierAccountNumber:String, lastVerifyCode:String):Void {		
		var serviceName = ServiceNameConst.VERIFY_SERVICE;
		var methodName = ServiceNameConst.VERIFY_METHOD;		
		GlobalMessageController.setMessage("Verifying order options...");		
		requestData(serviceName, methodName, this, null, AdapterConst.AMF, mfrID, orderType, shipVia, freightTerms, carrierAccountNumber, lastVerifyCode);		
	}	
	
	public function verifyItems(suggestedPOVo:SuggestedPOVo):Void {		
		var serviceName = ServiceNameConst.VERIFY_ITEM_SERVICE;
		var methodName = ServiceNameConst.VERIFY_ITEM_METHOD;		
		GlobalMessageController.setMessage("Verifying items...");		
		requestData(serviceName, methodName, this, null, AdapterConst.AMF, suggestedPOVo);		
	}	
	
	public function submitPurchaseOrder():Void {		
		var serviceName = ServiceNameConst.PO_SERVICE;
		if (purchaseOrderVo.getCanChangeOrder() == true) {
			var methodName = ServiceNameConst.RESUBMIT_PO_METHOD;
		} else {
			var methodName = ServiceNameConst.SUBMIT_PO_METHOD;
		}	
		if (purchaseOrderVo.getSubmit() == 1) {
			if (purchaseOrderVo.getIsRemoveItem()) {
				removeItemsArray = purchaseOrderVo.getPoItems().slice();
			} else {
				removeItemsArray = null;
			}
			GlobalMessageController.setMessage("Submitting vendor order...");			
		} else if (purchaseOrderVo.getSubmit() == 2) {			
			GlobalMessageController.setMessage("Saving vendor order...");
			if (purchaseOrderVo.getIsRemoveItem()) {
				removeItemsArray = purchaseOrderVo.getPoItems().slice();
			} else {
				removeItemsArray = null;
			}
		}
		if (purchaseOrderVo.getCanChangeOrder() == true) {
			requestData(serviceName, methodName, this, null, AdapterConst.AMF, purchaseOrderVo, getChangeCancelRequest());
		} else {
			requestData(serviceName, methodName, this, null, AdapterConst.AMF, purchaseOrderVo);
		}
	}

	public function abortChangeOrder(abortAction:Number):Void {
		this.abortAction = abortAction;	  
		requestData(ServiceNameConst.ORDER_STATUS_CHANGE_CANCEL_SERVICE, ServiceNameConst.METHOD_NAME_PO_CHANGECANCEL_ABORT, this, null, AdapterConst.AMF, getChangeCancelRequest());
	}
	
	public function updateRestoredSavedOrdersArray(seReferenceNumber:String):Void {
		for (var i = 0; i < restoredSavedOrders.length; i++) {
			if (restoredSavedOrders[i].getSEReferenceNumber() == seReferenceNumber) {
				restoredSavedOrders.splice(i, 1);
				return;
			}
		}
	}
	
	// SERVICE CALLBACK SUCCESS
	
	public function onRequestComplete(msg:Object, serviceName:String, methodName:String):Void {			
		var mySEResponse:SEResponse = SEResponse(msg.result);		
		super.onRequestComplete();
		GlobalMessageController.setMessage("");
		if (serviceName == ServiceNameConst.ORDER_DEFAULT_SERVICE && methodName == ServiceNameConst.GET_PURCHASE_ORDER_DEFAULTS_METHOD) {	
	     	purchaseOrderDefaultsResponse = OrderDefaultResponse(mySEResponse.getFinalResponse());
			if (purchaseOrderDefaultsResponse.getAction() == OrderDefaultResponse.ACTION_ORDEROPTIONS_REFRESHED) {
				GlobalMessageController.setMessage(purchaseOrderDefaultsResponse.getCustomerMessage());
			}
			if (purchaseOrderDefaultsResponse.getAction() == OrderDefaultResponse.ACTION_INVALID_SHIPTO_STATE) {
				GlobalMessageController.setMessage(purchaseOrderDefaultsResponse.getCustomerMessage());
				restorePreviousDropShipAddress();
			} else {
				poHeaderVo = purchaseOrderDefaultsResponse.getPOHeader();
				customerInfoVo = poHeaderVo.getCustomerInfo();			
				defaultOrderOptionsVo = purchaseOrderDefaultsResponse.getDefaultOrderOptionsVo();			
				orderOptionsList = purchaseOrderDefaultsResponse.getOrderOptionList();			
				parcelShippingVo = purchaseOrderDefaultsResponse.getParcelShipping();
				freightShippingVo = purchaseOrderDefaultsResponse.getFreightShipping();			
				createShipToEnabled = purchaseOrderDefaultsResponse.getCreateShipToEnabled();
				dropShipEnabled = purchaseOrderDefaultsResponse.getDropShipEnabled();
				isBackendCallRequiredOnStateChange = purchaseOrderDefaultsResponse.getIsBackendCallRequiredOnStateChange();
				isSelectLocationVisible = purchaseOrderDefaultsResponse.getIsSelectLocationVisible();
				orderInfoPropertyVo = purchaseOrderDefaultsResponse.getOrderInfoPropertyVo();
				poHeaderOrderOptions = new POHeaderOrderOptions();			
				poHeaderOrderOptions.setDefaultOrderOptionsVo(defaultOrderOptionsVo);
				poHeaderOrderOptions.setOrderOptionList(orderOptionsList);
				poHeaderOrderOptions.setParcelShipping(parcelShippingVo);
				poHeaderOrderOptions.setFreightShipping(freightShippingVo);
				poHeaderOrderOptions.setCreateShipToEnabled(createShipToEnabled);
				poHeaderOrderOptions.setDropShipEnabled(dropShipEnabled);
				poHeaderOrderOptions.setIsBackendCallRequiredOnStateChange(isBackendCallRequiredOnStateChange);
				poHeaderOrderOptions.setIsSelectLocationVisible(isSelectLocationVisible);
				poHeaderOrderOptions.setOrderInfoPropertyVo(orderInfoPropertyVo);
				poHeaderOrderOptions.setShippingStateOrderOptionsAreRelativeTo(orderDefaultsRequestShippingState);
				updateShippingStateOrderOptionsAreRelativeTo();
				setOrderOptionsList(orderOptionsList);
				setDefaultOrderOptionsVo(defaultOrderOptionsVo);
				setParcelShippingVo(parcelShippingVo);
				setFreightShippingVo(freightShippingVo);			
				setCreateShipToEnabled(createShipToEnabled);			
				setDropShipEnabled(dropShipEnabled);			
				poHeaderVo.setShippingOption(new OrderOptionVo());			
				shippingOption = poHeaderVo.getShippingOption();			
				purchaseOrderVo.setPurchaseOrderHeader(poHeaderVo);			
				purchaseOrderDefaultsReply(OrderDefaultResponse(mySEResponse.getFinalResponse()));						
			}
		}		
		if (serviceName == ServiceNameConst.PO_SERVICE && (methodName == ServiceNameConst.SUBMIT_PO_METHOD || methodName == ServiceNameConst.RESUBMIT_PO_METHOD)) {
	     	purchaseOrderSubmitResponse = SubmitPoResponse(mySEResponse.getFinalResponse());		
	    	purchaseOrderSubmitReply(purchaseOrderSubmitResponse);			
		}		
		if (serviceName == ServiceNameConst.VERIFY_SERVICE && methodName == ServiceNameConst.VERIFY_METHOD) {
	    	verifyOrderOptionsReply(VerifyOrderResponse(mySEResponse.getFinalResponse()));			
		}		
		if (serviceName == ServiceNameConst.VERIFY_ITEM_SERVICE && methodName == ServiceNameConst.VERIFY_ITEM_METHOD) {
	    	verifyItemsReply(VerifyItemResponse(mySEResponse.getFinalResponse()));			
		}
		if (serviceName == ServiceNameConst.ORDER_STATUS_CHANGE_CANCEL_SERVICE && methodName == ServiceNameConst.METHOD_NAME_PO_CHANGECANCEL_ABORT) {
			if (this.abortAction == CANCEL_PO_ACTION_EDIT) {
				abortChangeOrderReply(SEResponse(mySEResponse.getFinalResponse()));
			}
		}		
	}	
	
	// SERVICE CALLBACK FAILURE	
	
	public function onRequestFault(msg:Object, serviceName:String, methodName:String):Void {		
		var statusMessage= msg.getMessage();		
		if (statusMessage != null && statusMessage.length > 0) {		  
		  	super.onRequestFault(msg, serviceName, methodName);			
			// TODO ERROR HANDLING FOR VIEW			
		}		
	}		
	
	// REPLY METHODS	
	
	public function purchaseOrderDefaultsReply (purchaseOrderDefaultsResponse:OrderDefaultResponse):Void {		
		onPurchaseOrderDefaultsReply(purchaseOrderDefaultsResponse);	
	}	
	
	public function purchaseOrderSubmitReply(purchaseOrderSubmitResponse:SubmitPoResponse):Void { 			
		onPurchaseOrderSubmitReply(purchaseOrderSubmitResponse);	
	}	
	
	public function verifyOrderOptionsReply(verifyOrderOptionsResponseObject:VerifyOrderResponse):Void {			
		onVerifyOrderOptionsReply(verifyOrderOptionsResponseObject);	
	}	
	
	public function verifyItemsReply(verifyItemsResponseObject:VerifyItemResponse):Void { 			
		onVerifyItemsReply(verifyItemsResponseObject);	
	}
	
	public function abortChangeOrderReply(seResponseObject:SEResponse):Void {
		onAbortChangeOrderReply(seResponseObject);
	}
	
	public function restorePreviousDropShipAddress():Void {
		onRestorePreviousDropShipAddress();
	}
	
	public function updateShippingStateOrderOptionsAreRelativeTo():Void {
		onUpdateShippingStateOrderOptionsAreRelativeTo();
	}

	// EVENT HANDLERS	
	
	public function onPurchaseOrderDefaultsReply(purchaseOrderDefaultResponse:OrderDefaultResponse):Void {	
		// EVENT HANDLER	
	}	
	
	public function onPurchaseOrderSubmitReply(purchaseOrderSubmitResponse:SubmitPoResponse):Void {	
		// EVENT HANDLER	
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	public function onUpdateShippingStateOrderOptionsAreRelativeTo():Void {
		// EVENT HANDLER
	}
	
	// SETTERS AND GETTERS
	
	public function setSuggestedPOArray(suggestedPOArray:Array, isRestoredOrder:Boolean, addedSuggestedPOArray:Array):Void {		
		this.suggestedPOArray = suggestedPOArray;
		if (isRestoredOrder){
			if (this.restoredSavedOrders == undefined) {
				this.restoredSavedOrders = new Array();
			}
			this.restoredSavedOrders = this.restoredSavedOrders.concat(addedSuggestedPOArray);
		} else if (!!restoredSavedOrders){
			for (var savedOrderIndex = 0; savedOrderIndex < restoredSavedOrders.length; savedOrderIndex++){
				var savedSEReferenceNumber:String = restoredSavedOrders[savedOrderIndex].getSEReferenceNumber();
				for (var index = 0; index < suggestedPOArray.length; index++) {
					if (savedSEReferenceNumber == suggestedPOArray[index].getSEReferenceNumber()){
						var newPOName:String = suggestedPOArray[index].getPOName();
						var newExternalVendorNumber:String = suggestedPOArray[index].getExternalVendorNumber();
						var newPOItems:Array = suggestedPOArray[index].getPoItems().slice();
						suggestedPOArray[index] = restoredSavedOrders[savedOrderIndex];
						suggestedPOArray[index].setPOName(newPOName);
						suggestedPOArray[index].setPoItems(newPOItems);
						suggestedPOArray[index].setExternalVendorNumber(newExternalVendorNumber);
					}
				}
			}
		}
	}
	
	public function getSuggestedPOArray():Array {		
		return suggestedPOArray;		
	}
	
	public function setPurchaseOrderVo(purchaseOrderVo:PurchaseOrderVo):Void {		
		this.purchaseOrderVo = purchaseOrderVo;		
	}
	
	public function getPurchaseOrderVo():PurchaseOrderVo {		
		return purchaseOrderVo;		
	}
	
	public function setPOHeaderVo(poHeaderVo:POHeaderVo):Void {		
		this.poHeaderVo;		
	}
	
	public function getPOHeaderVo():POHeaderVo {		
		return poHeaderVo;		
	}
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/}
		
}