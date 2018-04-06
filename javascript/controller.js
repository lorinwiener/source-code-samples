goog.provide("DRE");
goog.provide("DRE.Controller");

//************CONFIG constants***************
goog.require("CONFIG");

//*************DataProvider shared among all views********
goog.require("DRE.UI");
goog.require("DRE.DataProvider");

//**************Views***************
goog.require("DRE.views.MainMenu");
goog.require("DRE.views.RoomNumberEntry");

//************** Libs ****************
goog.require("goog.pubsub.PubSub");
goog.require("dtv.io.Remote");
goog.require("dtv.Background");
goog.require("UI");
goog.require("DRE.UI");

/**
 * DIRECTV Residential Experience Controller.
 * @constructor
 */
DRE.Controller = function(){
    console.log(" ### [INFO] Starting Dashboard, epoch:" + (new Date()).getTime());

    this.channel_ = new goog.pubsub.PubSub();

    this.dataProvider_ = new DRE.DataProvider(this, this.channel_);

    this.ui_ = new DRE.UI(this);

    this.rid_ = this.getRID();

    document.onkeydown = goog.bind(this.keyHandler_, this);

    window.onload = goog.bind(this.displayView, this, CONFIG.VIEWS.MAIN_MENU);

    window.onbeforeunload = goog.bind(this.onExit_, this);

    this.appHidden_ = false;

    this.secretCodeIndex_ = 0;

    window.addEventListener("message", goog.bind(this.onReceiveMessage_,this), false);
    this.supressKeyHandler_ = false;
};

/**
 * Gets the reference to a DRE.view. If the view hasn't been instantiated, it instantiates it and returns it.
 * @public
 * @param  {CONFIG.VIEWS} viewEnum The id of the view
 * @return {DRE.views.MainMenu}     Reference to the view.
 */
DRE.Controller.prototype.getView = function(viewEnum){
	if(!this[viewEnum]){
		this[viewEnum] = this.createView_(viewEnum);
	}

	return this[viewEnum];
};

/**
 * Creates a new instance of a view.
 * All views must be listed here, cannot use ["String"] notation because of ADVANCED_OPTIMIZATIONS renaming.
 * @private
 * @param  {CONFIG.VIEWS} viewEnum The id of the view
 * @return {DRE.views.MainMenu}    Reference to the view
 */
DRE.Controller.prototype.createView_ = function(viewEnum){
    var enm      = CONFIG.VIEWS,
        tempView = null;

    switch(viewEnum){
        case enm.MAIN_MENU:
            tempView = new DRE.views.MainMenu(this, this.ui_, this.dataProvider_, this.channel_);
            break;
        case enm.ROOM_NUMBER_ENTRY:
            tempView = new DRE.views.RoomNumberEntry(this, this.ui_, this.dataProvider_, this.channel_);
            break;
    }

    //tempView.display();//ADDED FOR ADVANCED OPTIMIZATIONS

    return tempView;
};

/**
 * Disposes the view by calling its dispose() method and then calling the garbage collector.
 * @public
 * @param  {CONFIG.VIEWS} viewEnum The id of the view
 */
DRE.Controller.prototype.disposeView = function(viewEnum){
	var view = this[viewEnum];
	if(view){
		view.dispose();
		this[viewEnum] = null;
		if(navigator.gc){
			navigator.gc(0);
		}
	}
};

/**
 * Calls the display() method of a view.
 * @public
 * @param  {CONFIG.VIEWS} viewEnum The id of the view
 */
DRE.Controller.prototype.displayView = function(viewEnum){
    var view = this[viewEnum];
    if(!view){
        view = this.getView(viewEnum);
    }

    view.display();//REMOVED FOR ADVANCED OPTIMIZATIONS
};

/**
 * Sets the property focused_ on a view so the keyHandler delegates to that specific view
 * @public
 * @param  {DRE.views.MainMenu} view Reference to the view we want to focus
 */
DRE.Controller.prototype.focusView = function(view){
	this.focused_ = view;
};

/**
 * Gets the reference to the currently focused view.
 * @public
 * @return {DRE.views.MainMenu} Reference to the currently focused view
 */
DRE.Controller.prototype.getFocusedView = function(){
	return this.focused_;
};

/**
 * Allows views to post messages to app_loader
 * @private
 * @param  {string}  message value to display
 * @param  {string}  location to post message to
 * @param  {boolean} supressKeyHandler if evaluates to true, keyspresses are ignored untill failure or app switch.
 */
DRE.Controller.prototype.postMessage = function(message,location,supressKeyHandler)
{
    window.top.postMessage(message, location);
    this.supressKeyHandler_ = supressKeyHandler ?  true : false ;
};

/**
 * Handles postMessages from app_loader
 * @private
 * @param  {Event} event from window.postmessage call
 */
DRE.Controller.prototype.onReceiveMessage_ = function(event)
{
    window.console.log("### [INFO] Dashboard received message " + event.data);
    var data = JSON.parse(event.data);
    if (!data.type && !data.action) {
        console.log('ERROR: invalid message' + data);
        return;
    }

    if (data.type == 'failure' && data.action == "switch")
    {
        this.supressKeyHandler_ = false;
    }
};


/**
 * Handles the key press event for the whole application. Delegates the handling to the currently focused view.
 * @param  {!Object} key the key event to handle
 * @return {!boolean} true if middleware should process the keypress
 */
DRE.Controller.prototype.keyHandler_ = function(key){
    window.console.log("***keyPressed: "+key.keyCode);
    var passBackToMW = false,
        keys         = dtv.io.Remote;
    if(this.supressKeyHandler_){return passBackToMW;}
    // The views keyHandler returns true if key was not handled
    var moreKeyHandlingNeeded = this.focused_.keyHandler(key);

    if(moreKeyHandlingNeeded){
        //Never pass INFO key back to Middleware
        if(key.keyCode == keys.INFO){
            passBackToMW = false;
        }
        //currently no key exists that gets passed back to Middleware
        else if (keys.NUMPAD.indexOf(key.keyCode) !== -1) {
            //window.console.log("*** Number key pressed: " + key.keyCode + " ***");
            if (DRECust.showRoomAssignment == true) {
              this.checkSecretCode_(key.keyCode);
            }
 	          //passBackToMW = true;
        }
        else if ( key.keyCode == keys.PREV)
        {
            passBackToMW = true;
        }
    }
    return passBackToMW;
};

/**
 * Checks number keys against the secret code assigned via the admin tool.
 * @param  {number} key keycode
 * @private
 */
DRE.Controller.prototype.checkSecretCode_ = function(key){
    var num = key - 48;

    clearTimeout(this.resetTimeout);

    if(num == DRECust.secretCode.charAt(this.secretCodeIndex_)) {
        console.log("match!");
        this.secretCodeIndex_++;

        //Set timeout so that if the user doesn't enter another number in a set amount of time
        //the secret code will reset. Timeout is cleared every time a correct number is entered.
        this.resetTimeout = setTimeout(goog.bind(this.resetSecretCode_, this), 3000);
    } else {
        //If the current number sequence does not match, reset the code.
        this.resetSecretCode_();
    }

    if(this.secretCodeIndex_ == DRECust.secretCode.length) {
        this.displayView(CONFIG.VIEWS.ROOM_NUMBER_ENTRY);
        this.resetSecretCode_();
    }
};

/**
 * Reset the secret code index
 * @private
 */
DRE.Controller.prototype.resetSecretCode_ = function(){
    console.log("secret code is cleared!");
    this.secretCodeIndex_ = 0;
};

/**
 * @public
 */
DRE.Controller.prototype.dontclear = function(){
	this.dontclear_ = true;
};

/**
 * Callback function when the window.unload event fires.
 * Exits the fullscreen.
 * @private
 */
DRE.Controller.prototype.onExit_ = function(){
    window.console.log("### [INFO] Dashboard exiting");
    document.body.classList.add("hidden");
    var bg = dtv.Background.NO_BACKGROUND,
        ba = document.getElementById("banner-ad");

    ba.parentNode.removeChild(ba);
    dtv.Background.set( bg, bg, dtv.Background.PRESETS.FS_PIG );

    if (!!navigator.gc) {
        navigator.gc();
        navigator.gc(2);
    }
//	if(!this.dontclear_)
//	{
//		document.body.classList.add("hidden");
//		dtv.Background.clear();
//		window.console.log(" ******************* onExit_ **************** ");
//		//navigator.clearBackground(0, 0, 1920, 1080);
//        //VideoSource.setFullScreen();
//        //navigator.Exit();
//	}
    // new dtv.fs.Fullscreen(dtv.Background.NO_BACKGROUND);
};

/**
 * Hides the app, shows the snipe icon and shows full screen live TV
 * @public
 */
DRE.Controller.prototype.hideApp = function(){
	this.ui_.changeBackground(dtv.Background.NO_BACKGROUND);
	UI.hideEl("app");
	UI.showEl("snipe");
	this.appHidden_ = true;

	window.setTimeout(function(){
		UI.hideEl("snipe");
	},5000);
};

/**
 * Shows the app after it's been hidden, hides the snipe and brings the main menu
 * @public
 */
DRE.Controller.prototype.showApp = function(){
	//this.displayView(CONFIG.VIEWS.MAIN_MENU);
	UI.hideEl("snipe");
	UI.showEl("app");
	this.appHidden_ = false;
};


/**
 * Capture and calculate the Receiver ID, used in accessing the PMS
 * @public
 * @return {?string}
 */
DRE.Controller.prototype.getRID = function() {
    var rid = null,
        calcCheck = function (num) {
        var pNum = parseInt(num, 10),
            oddSum = 0,
            evenSum = 0,
            n = pNum,
            digit = 0;
        for (var i = 1; i <= 12; i++) {
            digit = parseInt(n % 10, 10);
            n = parseInt(n / 10, 10);
            if (i % 2 == 1) {
                digit = digit * 2;
                if (digit >= 10) {
                    digit = digit - 9;
                }
                oddSum = oddSum + digit;
            } else {
                evenSum = evenSum + digit;
            }
        }

        return (10 - (evenSum + oddSum) % 10) % 10;
    },
        padDecId = function (decId) {
            var curId = decId;
            while (curId.length < 11) {
                curId = "0" + curId;
            }
            return curId;
        };

    if (!!navigator.stbIdentity) {
        var hexRecId = navigator.stbIdentity.substring(6, 14),
            decRecId = padDecId("" + parseInt(hexRecId, 16)),
            chkDigit = calcCheck(decRecId),
            recId    = "" + decRecId + chkDigit;

        rid = recId;
        console.log("STB RID: " + rid);
    }

    return rid;
};

//Get the wheel moving
new DRE.Controller();
