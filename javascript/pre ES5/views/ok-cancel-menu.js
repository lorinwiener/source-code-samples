goog.provide("DRE.views.OkCancelMenu");

//************** Libs ****************
goog.require("dtv.io.Remote");
goog.require("UI");

/**
 * View for ok/cancel sub menu
 * @constructor
 * @param {!string}   containerId      The menu container
 * @param {!Function} okCB         	   Callback when user presses ok
 * @param {!Function} cancelCB         Callback when user presses cancel
 * @param {Function=} lostFocusCB      Callback when menu lost focus
 */
DRE.views.OkCancelMenu = function(containerId, okCB, cancelCB, lostFocusCB) {
	this.domId_ = containerId;
	this.okCB_ = okCB;
	this.cancelCB_ = cancelCB;
	this.lostFocusCB_ = lostFocusCB;

	this.isDOMCreated_ = false;
	this.activeIndex_ = 0;
	this.a_buttons_  = [];

	this.createDOM_();
};

/**
 * Creates the Dom for this view
 * @private
 */
DRE.views.OkCancelMenu.prototype.createDOM_ = function() {
	var view = document.getElementById(this.domId_);

	var okButton = document.createElement("div");
		okButton.setAttribute("id", "rne-ok-button");
		okButton.classList.add("rne-ok-button");

	var cancelButton = document.createElement("div");
		cancelButton.setAttribute("id", "rne-cancel-button");
		cancelButton.classList.add("rne-cancel-button");

	view.appendChild(okButton);
	view.appendChild(cancelButton);

	this.a_buttons_.push(okButton);
	this.a_buttons_.push(cancelButton);
};

/**
 * Displays this view
 * @public
 */
DRE.views.OkCancelMenu.prototype.display = function() {
	this.activeIndex_ = 0;
	UI.showEl(this.domId_);
};

/**
 * Hides this view
 * @public
 */
DRE.views.OkCancelMenu.prototype.hide = function() {
	UI.hideEl(this.domId_);
};

/**
 * Disposes this view
 * @public
 */
DRE.views.OkCancelMenu.prototype.dispose = function() {

};

/**
 * Handles the key press event when the focus is on this view
 * @param  {Object} key
 * @return {!boolean} true if middleware should process the keypress
 *                    further, false otherwise
 */

/**
 * Handle when menu gets focus
 * @public
 */
DRE.views.OkCancelMenu.prototype.focus = function() {
	this.activeIndex_ = 0;
	this.a_buttons_[this.activeIndex_].classList.add("active");
};

/**
 * Handle when menu loses focus
 * @public
 */
DRE.views.OkCancelMenu.prototype.lostFocus = function() {
	this.a_buttons_[this.activeIndex_].classList.remove("active");
};

/**
 * Handle key press
 *
 * @param  {!Object} key the key event to handle
 * @return {boolean} False to tell the STB that the application handled the key
 *         so middleware does nothing. True to tell the STB to handle the event
 * @public
 */
DRE.views.OkCancelMenu.prototype.keyHandler = function(key){
	var keys = dtv.io.Remote,
		passBackToMW = false;

	if(key.keyCode == keys.UP && this.activeIndex_ > 0) {
		this.a_buttons_[this.activeIndex_].classList.remove("active");
		this.activeIndex_--;
		this.a_buttons_[this.activeIndex_].classList.add("active");
	} else if (key.keyCode == keys.DOWN && this.activeIndex_ < this.a_buttons_.length - 1) {
		this.a_buttons_[this.activeIndex_].classList.remove("active");
		this.activeIndex_++;
		this.a_buttons_[this.activeIndex_].classList.add("active");
	} else if (key.keyCode == keys.LEFT) {
		this.lostFocus();
		this.lostFocusCB_();
	} else if (key.keyCode == keys.SELECT) {
		this.onSelect_();
	} else {
		passBackToMW = true;
	}

	return passBackToMW;
};

/**
 * Hanling when user selects a button
 * @private
 */
DRE.views.OkCancelMenu.prototype.onSelect_ = function(){
	switch(this.activeIndex_) {
		case 0:
			this.okCB_();
			break;
		case 1:
			this.cancelCB_();
			break;
	}

	this.lostFocus();
};
