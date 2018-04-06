goog.provide("DRE.views.RoomNumberEntry");

//************** Libs ****************
goog.require("dtv.io.Remote");
goog.require("dtv.ajax");
goog.require("dtv.ui.Keyboard");
goog.require("UI");

//**************Views***************
goog.require("DRE.views.OkCancelMenu");

/**
 * View for manual room number entry that is accessed by entering a secret code
 * from the DRE dashboard home screen.
 * @constructor
 * @param {Object} controller   Reference to the Controller
 * @param {Object} ui           Reference to DRE.UI
 * @param {Object} dataProvider Reference to DRE.DataProvider
 * @param {Object} channel      The PubSub channel to communicate between controller and views
 */
DRE.views.RoomNumberEntry = function(controller, ui, dataProvider, channel) {
	this.controller_ = controller;
	this.ui_ = ui;
	this.dataProvider_ = dataProvider;
	this.channel_ = channel;
	this.ids_ = CONFIG.IDS.ROOM_NUMBER_ENTRY;

	this.focused_ = 0;
	this.keyboard_ = null;
	this.okCancelMenu_ = null;

	this.createDOM_();
};

/**
 * Displays this view
 * @public
 */
DRE.views.RoomNumberEntry.prototype.display = function() {
	this.focused_ = 0;
	this.keyboard_.display();
	this.okCancelMenu_.display();
	this.ui_.display(CONFIG.BACKGROUNDS.MAIN_MENU,  DRECust.backgroundHD, DRECust.backgroundNormal, CONFIG.SCREENS.ROOM_NUMBER_ENTRY, this.ids_.CONTAINER, dtv.Background.PRESETS.FS_PIG);
	this.controller_.focusView(this);
};

/**
 * Hides this view
 * @public
 */
DRE.views.RoomNumberEntry.prototype.hide = function() {
	UI.hideEl(this.ids_.CONTAINER);
};

/**
 * Disposes this view
 * @public
 */
DRE.views.RoomNumberEntry.prototype.dispose = function() {
	var viewDOM = document.getElementById(this.ids_.CONTAINER);
		viewDOM.parentNode.removeChild(viewDOM);
};

/**
 * Handles the key press event when the focus is on this view
 * @param  {Object} key
 * @return {!boolean} true if middleware should process the keypress
 *                    further, false otherwise
 */
DRE.views.RoomNumberEntry.prototype.keyHandler = function(key){
	var keys = dtv.io.Remote,
		passBackToMW = false;

	if (this.focused_ === 0) {
		passBackToMW = this.keyboard_.keyHandler(key);
	} else {
		passBackToMW = this.okCancelMenu_.keyHandler(key);
	}

	return passBackToMW;
};

/**
 * Creates the Dom for this view
 * @private
 */
DRE.views.RoomNumberEntry.prototype.createDOM_ = function() {
	var app = document.getElementById("app");

	var view = document.createElement("div");
		view.setAttribute("id", this.ids_.CONTAINER);
		view.classList.add("hidden");

	var keyboardContainer = document.createElement("div");
		keyboardContainer.setAttribute("id", this.ids_.KEYBOARD_CONTAINER);


	var keyboard = document.createElement("div");
		keyboard.setAttribute("id", this.ids_.KEYBOARD);

	var instrucs = document.createElement("p");
		instrucs.setAttribute("id", this.ids_.INSTRUCS);
		instrucs.innerHTML = "Enter Room Number";
		instrucs.style.fontSize = 40 + "px";

	var okCancelMenu = document.createElement("div");
		okCancelMenu.setAttribute("id", this.ids_.OK_CANCEL_MENU);

		keyboardContainer.appendChild(instrucs);
		keyboardContainer.appendChild(keyboard);
		keyboardContainer.appendChild(okCancelMenu);
		view.appendChild(keyboardContainer);
		app.appendChild(view);

	this.keyboard_ = new dtv.ui.Keyboard(
							this.ids_.KEYBOARD,
							"assets/images/keyboard.png",
							26,
							null,
							goog.bind(function() {
								this.focused_ = 1;
								this.okCancelMenu_.focus();
							}, this)
						);

	this.okCancelMenu_ = new DRE.views.OkCancelMenu(
							this.ids_.OK_CANCEL_MENU,
							goog.bind(function() {
								//When OK is pressed
								//send room number to MCS, refresh displayed room number, return to main menu
								var mainMenu = this.controller_.getView(CONFIG.VIEWS.MAIN_MENU);
								this.dataProvider_.sendRoomNumber(this.keyboard_.getText(), goog.bind(mainMenu.updateGuest_, mainMenu));
								this.hide();
								this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
							}, this),
							goog.bind(function() {
								//When Cancel is pressed
								//return to main menu
								this.hide();
								this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
							}, this),
							goog.bind(function() {
								this.focused_ = 0;
								this.keyboard_.focus();
							}, this)
						);
};
