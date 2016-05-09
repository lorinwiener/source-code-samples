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
 * PurchaseOrderView is responsible for rendering and manipulating the presentation of the Purchase Order
 * that is displayed when the user selects the "Purchase Order" tab in the Tabs view.
 * 
 *
 */

import com.smartequip.core.view.SEBaseView;
import com.smartequip.core.sebo.AddressVo;
import com.smartequip.core.sebo.po.PurchaseOrderVo;
import com.smartequip.core.sebo.po.POHeaderVo;
import com.smartequip.core.sebo.po.CustomerInfoVo;
import com.smartequip.core.sebo.po.SuggestedPOVo;
import com.smartequip.core.sebo.po.SubmitPoResponse;
import com.smartequip.core.sebo.po.OrderInfoPropertyVo;
import mx.utils.Delegate;
import mx.controls.Button;
import mx.controls.ComboBox;
import com.utils.Utils;
import com.smartequip.epro.bridge.LegacyBridge;

class com.smartequip.epro.view.PurchaseOrderView extends SEBaseView {
	
	private var purchaseOrderVo:PurchaseOrderVo;
	private var poHeaderVo:POHeaderVo;
	private var customerInfoVo:CustomerInfoVo;	
	private var suggestedPOArray:Array;
	private var suggestedPOVo:SuggestedPOVo;
	private var poItemsArray:Array;	
	private var addressesContainer_mc:MovieClip;
	private var orderInformationContainer_mc:MovieClip;
	private var itemsContainer_mc:MovieClip;	
	private var purchaseOrderBackground_mc:MovieClip;
	private var purchaseOrderComments_mc:MovieClip;		
	private var purchaseOrderSelector_cb:ComboBox;	
	private var customerAccountNumber_txt:TextField;
	private var seReferenceNumber_txt:TextField;
	private var purchaseOrderIdentifier_txt:TextField;
	private var currency_txt:TextField;
	private var total_txt:TextField;
	private var purchaseOrderComments_txt:TextField;	
	private var returnItemsToCart_btn:Button;
	private var comments_btn:Button;
	private var modifyOrder_btn:Button;
	private var verify_btn:Button;
	/* 
	  // This portion of code hidden for proprietary purposes
	*/

	
	// CONSTRUCTOR	
	
	public function PurchaseOrderView() {		
		init();		
	}	
	
	// INITIALIZE	
	
	private function init() {		
		isInitView = false;
		this._visible = false;
	}
	
	
	public function initView() {		
		isInitView = true;
		setButtonTabEnabled(false);		
		setButtonHandlers();		
		setChangeHandlers();
		setVisible("iconPOChange_mc", false);
		setVisible("close_btn", false);
		setVisible("modifyItemsForPOChange_btn", false);
		purchaseOrderSelector_cb.dropdown.hScrollPolicy = "on";
		purchaseOrderSelector_cb.dropdown.maxHPosition = 200;
		purchaseOrderSelector_cb.tabEnabled = false;
		resetPOCommentsVisibility();
		populatePurchaseOrderSelectorComboBox();		
		this._visible = true;		
	}	
	
	// MODULE VIEW METHODS	
		
	public function returnItemsToCartButtonRelease():Void {		
		onReturnItemsToCartButtonRelease();		
	}	
	
	public function commentsButtonRelease():Void {
		togglePurchaseOrderCommentsVisibility();
		onCommentsButtonRelease();		
	}	
	
	public function printButtonRelease():Void {		
		onPrintButtonRelease();		
	}	
	
	public function saveButtonRelease():Void {		
		onSaveButtonRelease();		
	}	
	
	public function submitButtonRelease():Void {		
		onSubmitButtonRelease();		
	}
		
	public function modifyOrderButtonRelease():Void {
		onModifyOrderButtonRelease();		
	}
	
	public function verifyButtonRelease():Void {		
		onVerifyButtonRelease();		
	}
	
	public function closeButtonRelease():Void {
		onCloseButtonRelease();		
	}
	
	public function modifyItemsForPOChangeButtonRelease():Void {		
		onModifyItemsForPOChangeButtonRelease();		
	}
	
	public function purchaseOrderSelectorChanged():Void {		
		onPurchaseOrderSelectorChanged();		
	}	
	
	public function purchaseOrderCommentsChanged(textfield_txt:TextField):Void {		
		onPurchaseOrderCommentsChanged(textfield_txt);		
	}	
	
	private function setButtonTabEnabled(toggle:Boolean) {		
		returnItemsToCart_btn.tabEnabled = toggle;
		comments_btn.tabEnabled = toggle;
		verify_btn.tabEnabled = toggle;
		print_btn.tabEnabled = toggle;
		save_btn.tabEnabled = toggle;
		submit_btn.tabEnabled = toggle;	
		close_btn.tabEnabled = toggle;	
		modifyItemsForPOChange_btn.tabEnabled = toggle;	
	}		
	
	private function setChangeHandlers() {		
		purchaseOrderSelector_cb.addEventListener("change", Delegate.create(this, purchaseOrderSelectorChanged));
		purchaseOrderBackground_mc.purchaseOrderComments_mc.purchaseOrderComments_txt.onChanged = Delegate.create(this, purchaseOrderCommentsChanged);
		purchaseOrderBackground_mc.purchaseOrderComments_mc.purchaseOrderComments_txt.maxChars = 240;
	}	
	
	private function setButtonHandlers() {		
		returnItemsToCart_btn.addEventListener("click", Delegate.create(this, returnItemsToCartButtonRelease));
		comments_btn.addEventListener("click", Delegate.create(this, commentsButtonRelease));
		print_btn.addEventListener("click", Delegate.create(this, printButtonRelease));
		save_btn.addEventListener("click", Delegate.create(this, saveButtonRelease));
		submit_btn.addEventListener("click", Delegate.create(this, submitButtonRelease));
		verify_btn.addEventListener("click", Delegate.create(this, verifyButtonRelease));
		modifyOrder_btn.addEventListener("click", Delegate.create(this, modifyOrderButtonRelease));
		close_btn.addEventListener("click", Delegate.create(this, closeButtonRelease));
		modifyItemsForPOChange_btn.addEventListener("click", Delegate.create(this, modifyItemsForPOChangeButtonRelease));
	}
	
	public function configurePurchaseOrder(argSuggestedPOVo:SuggestedPOVo):Void {
		var canChangeOrder:Boolean = argSuggestedPOVo.getCanChangeOrder();
		setVisible("returnItemsToCart_btn", !canChangeOrder);
		setVisible("modifyOrder_btn", !canChangeOrder);
		setVisible("verify_btn", !canChangeOrder);
		setVisible("save_btn", !canChangeOrder);
		setVisible("close_btn", canChangeOrder);
		setVisible("modifyItemsForPOChange_btn", canChangeOrder);
		if (canChangeOrder == true) {
			submit_btn.label = "Re-Submit";
			setVisible("iconPOChange_mc", true);
			statusText_txt._x = 328.8;
		} else {
			submit_btn.label = "Submit";
			setVisible("iconPOChange_mc", false);
			statusText_txt._x = 346.08;
		}
		if(argSuggestedPOVo.getCanSubmitOrder() == false){
			submit_btn._visible = false;
		} else {
			submit_btn._visible = true;
		}
	}
		
	private function populatePurchaseOrderFields(suggestedPOArray:Array, purchaseOrderVo:PurchaseOrderVo, customerInfoVo:CustomerInfoVo, poHeaderVo:POHeaderVo):Void {		
		this.suggestedPOArray = suggestedPOArray;
		this.purchaseOrderVo = purchaseOrderVo;
		this.customerInfoVo = customerInfoVo;
		this.poHeaderVo = poHeaderVo;		
		populatePurchaseOrderIdentifierField();
		populateStatusField();
		populateCustomerAccountNumberField();		
		populateSEReferenceNumberField();		
		populatePurchaseOrderComments();		
		populateCurrencyField();		
		populateTotalField();		
		populatePoDefaults();		
	}	
	
	public function populatePurchaseOrderSelectorComboBox(suggestedPOArray:Array) {
		purchaseOrderSelector_cb.dropdown.setStyle("iconField", "icon");
		if (suggestedPOArray != undefined) {			
			this.suggestedPOArray = suggestedPOArray;			
		}	
		if (isInitView && this.suggestedPOArray != undefined) {		
			toggleMultiVendorUI();			
			clearPurchaseOrderSelectorComboBox();				
			for (var i = 0; i < this.suggestedPOArray.length; i++) {				
				var suggestedPOVo:SuggestedPOVo = this.suggestedPOArray[i];			
				var vendorID:String = suggestedPOVo.getVendorID();
				var poName:String = suggestedPOVo.getPOName();
				if (suggestedPOVo.getCanChangeOrder() == true) {
					setPurchaseOrderSelectorComboBox({label:poName, data:suggestedPOVo, icon:"iconPOChange_mc"});
				} else {
					setPurchaseOrderSelectorComboBox({label:poName, data:suggestedPOVo, icon:""});
				}
			}			
			purchaseOrderSelector_cb.selectedIndex = suggestedPOArray.length - 1;			
		}				
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
	public function populateStatusField():Void {		
		var status:String = getSuggestedPOVo().getStatusDescription().toUpperCase();
		if (status == undefined) {
			status = "NEW";
		}
		statusText_txt.text = "STATUS: " + status;	
	}
	
	public function populateCustomerAccountNumberField() {		
		customerAccountNumber = customerInfoVo.getCustomerAccountNumber();		
		setCustomerAccountNumberField(customerAccountNumber);		
	}	
	
	public function populateSEReferenceNumberField() {		
		var suggestedPOVo = getSuggestedPOVo();		
		seReferenceNumber = suggestedPOVo.getSEReferenceNumber();		
		setSEReferenceNumberField(SEReferenceNumber);		
	}	
	
	public function populatePurchaseOrderComments() {		
		var comment:String = poHeaderVo.getPurchaseOrderComment();		
		setPurchaseOrderCommentsField(comment);		
	}	
	
	public function populateCurrencyField() {		
		var addressVo:AddressVo;		
		var addressArray:Array;
		var currency:String;
		currency = poHeaderVo.getCurrency();		
		setCurrencyField(currency);		
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/	
	
	public function toggleMultiVendorUI() {		
		if (suggestedPOArray.length > 1) {			
			setVisible("purchaseOrderSelector_cb", true);			
		} else {			
			setVisible("purchaseOrderSelector_cb", false);			
		}		
	}	
	
	public function clearPurchaseOrderSelectorComboBox() {		
		purchaseOrderSelector_cb.removeAll();		
	}	
	
	public function clearCustomerAccountNumberField() {		
		customerAccountNumber_txt.text = "";		
	}	
	
	public function clearSEReferenceNumberField() {		
		seReferenceNumber_txt.text = "";		
	}	
	
	public function clearPurchaseOrderIdentifierField() {		
		purchaseOrderIdentifier_txt.text = "";		
	}	
	
	public function togglePurchaseOrderCommentsVisibility() {	
		var visible = purchaseOrderBackground_mc.purchaseOrderComments_mc._visible;		
		if (visible == false) {		
			comments_btn.label = "Hide Comments";			
			purchaseOrderBackground_mc.purchaseOrderComments_mc._visible = true;		
			purchaseOrderBackground_mc.purchaseOrderComments_mc.focusEnabled = true;			
		} else {		
			comments_btn.label = "Show Comments";			
			purchaseOrderBackground_mc.purchaseOrderComments_mc._visible = false;		
			purchaseOrderBackground_mc.purchaseOrderComments_mc.focusEnabled = false; // THIS IS DONE SO THE TEXT FIELDS IN THE VENDOR ORDER COMMENTS DON'T INTERCEPT FOCUS OF VENDOR ORDER LINE ITEMS
		}		
	}	
	
	public function toggleSubmitButtonEnabled(submitPoFlag:String) {		
		if (submitPoFlag == "Y") {			
			submit_btn.enabled = true;			
		} else {			
			submit_btn.enabled = false;			
		}		
	}	
	
	public function resetPOCommentsVisibility():Void {	
		purchaseOrderBackground_mc.purchaseOrderComments_mc._visible = false;		
		purchaseOrderBackground_mc.purchaseOrderComments_mc.focusEnabled = false; // THIS IS DONE SO THE TEXT FIELDS IN THE VENDOR ORDER COMMENTS DON'T INTERCEPT FOCUS OF VENDOR ORDER LINE ITEMS
	}	
	
	public function setVisible(instanceName:String, visible:Boolean):Void {		
		var instance:Object;		
		if (!instanceName.length > 0) {			
			instance = this;			
		} else {			
			instance = this[instanceName];			
		}		
		instance._visible = visible;		
	}	
	
	public function openPurchaseOrderShippingOptionsDialogBox():Void {		
		onOpenPurchaseOrderShippingOptionsDialogBox();		
	}	
	
	public function acceptQuantityChange() {		
		onAcceptQuantityChange();		
	}	
	
	public function nextOrder():Void {		
		onNextOrder();		
	}	
	
	public function returnToCart():Void {		
		onReturnToCart();		
	}	
	
	public function viewOrderStatus():Void {		
		onViewOrderStatus();		
	}  
	
 	// DELEGATE HANDLER CALLBACKS
	
	// EVENT HANDLERS	
	
	private function onReturnItemsToCartButtonRelease():Void {		
		// EVENT HANDLER		
	}	
	
	private function onCommentsButtonRelease():Void {		
		// EVENT HANDLER		
	}		
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/	
	
	// SETTERS AND GETTERS	
	
	public function getAddressesContainer():MovieClip {		
		return addressesContainer_mc;		
	}	
	
	public function getOrderInformationContainer():MovieClip {		
		return orderInformationContainer_mc;		
	}	
	
	public function getItemsContainer():MovieClip {		
		return itemsContainer_mc;		
	}
	
	public function setPurchaseOrderSelectorComboBox(obj:Object):Void {		
		purchaseOrderSelector_cb.addItem(obj);		
	}	
	
	public function getSuggestedPOVo():SuggestedPOVo {		
		var selectedItemData = purchaseOrderSelector_cb.selectedItem.data;		
		return SuggestedPOVo(selectedItemData);		
	}	
	
	/* 
	  // This portion of code hidden for proprietary purposes
	*/
	
}