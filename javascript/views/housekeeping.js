goog.provide("DRE.views.Housekeeping");

goog.require("dtv.io.Remote");
goog.require("dtv.scroll.Scrollbar");

/**
 * The Housekeeping view is a simple "panel" layout, very similar to Info Panel
 * @constructor
 * @param {!DRE.Controller}     controller   the Controller object handling the views
 * @param {!DRE.UI}             ui           the UI object handling screen manipulation
 * @param {!DRE.DataProvider}   dataProvider the data supply
 * @param {!goog.pubsub.PubSub} channel      the PubSub channel for controller-view communication
 */
DRE.views.Housekeeping = function(controller, ui, dataProvider, channel) {
    this.controller_ = controller;
    this.ui_ = ui;
    this.dataProvider_ = dataProvider;
    this.channel_ = channel;
    this.ids_ = CONFIG.IDS.HOUSEKEEPING;
    this.build_ = false;
    this.scrollbar_ = null;
    this.done_ = null;

    this.setFocus_();
    this.content_ = "";
};

/**
 * Displays the Housekeeping view
 * @public
 */
DRE.views.Housekeeping.prototype.display = function () {
    this.ui_.display(CONFIG.BACKGROUNDS.HOUSEKEEPING, DRECust.backgroundHD, DRECust.backgroundNormal, CONFIG.SCREENS.HOUSEKEEPING, this.ids_.CONTAINER);
    this.controller_.focusView(this);

    if (!this.built_) {
        this.buildDynamicContent_();
		//buildDynamicContent_() - places callback to: populateInfo_()
		//       populateInfo_() - calls: buildScrollbar_()
		//     buildScrollbar_() - places callback to: callBackDisplayDone_() <if no scrollbar created>
    } else {
        this.focusSomething_();
        this.scrollbar_.onFocus();
    }

    UI.showEl(this.ids_.SCROLLBAR_CONTENT);
};

DRE.views.Housekeeping.prototype.hide = function () {
    UI.hideEl(this.ids_.CONTAINER);
};

/**
 * Disposes the housekeeping view
 * @public
 */
DRE.views.Housekeeping.prototype.dispose = function () {
    this.scrollbar_ = null;
    this.content_ = "";
    this.done_ = null;
};

/**
  * @return {boolean}
  * returns true if scrollbar is visible
  * returns false if scrollbar is hidden (and done/okay is visible)
  */
DRE.views.Housekeeping.prototype.scrollbarIsVisible_ = function(){
    return ((!this.scrollbar_.track.classList.contains("hidden")) ? true : false);
};

DRE.views.Housekeeping.prototype.keyHandler = function (key) {
    var keys = dtv.io.Remote;
	//No Scrollbar (Just a Done button)
    if(!this.scrollbarIsVisible_() )
    {
        if(key.keyCode==keys.LEFT || key.keyCode==keys.SELECT){
            this.setFocus_();//removes focus
            this.hide();//hides Housekeeping
            this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
        }
        return true;
    }
    else{//Just A Scrollbar:
        switch(key.keyCode){
        case keys.LEFT://Left
            this.scrollbar_.lostFocus();
            this.hide();//hides Housekeeping
            this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
            this.setFocus_();//removes focus
            break;
		case keys.PAGEUP:
		case keys.PAGEDOWN:
        case keys.DOWN://Down
        case keys.UP://Up
            //if( this.scrollbar_.YPos < this.scrollbar.maxYPos ){
            this.scrollbar_.keyHandler(key);
            //}
            break;
        }
        return true;
    }/*//how worked previously when both done and scrollbar both always displayed.
    switch (key.keyCode) {
    case keys.LEFT:
        if (this.focused_ === this.scrollbar_) {
            this.scrollbar_.lostFocus();
            this.hide();
            this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
            this.setFocus_();
        } else {
            this.scrollbar_.onFocus();
            this.setFocus_(this.scrollbar_);
            this.doneIdle_();
        }
        break;
    case keys.RIGHT:
        if (this.focused_ === this.scrollbar_) {
            this.setFocus_(this.done_);
            this.doneActive_();
            this.scrollbar_.lostFocus();
            break;
        }
    case keys.DOWN:
        if (this.focused_ === this.scrollbar_ &&
            this.scrollbar_.YPos >= this.scrollbar_.maxYPos &&
            key.keyCode === keys.DOWN) {
            this.scrollbar_.lostFocus();
            this.setFocus_(this.done_);
            this.doneActive_();
            break;
        }
    case keys.UP:
        if (this.focused_ === this.done_ &&
            key.keyCode === keys.UP) {
            this.doneIdle_();
            this.setFocus_(this.scrollbar_);
            this.scrollbar_.onFocus();
            break;
        }
    case keys.PAGEUP:
    case keys.PAGEDOWN:
    case keys.SELECT:
        if (this.focused_ === this.done_ &&
            key.keyCode === keys.SELECT) {
            this.doneIdle_();
            this.setFocus_();
            this.hide();
            this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
        } else if (this.focused_ === this.scrollbar_) {
            this.scrollbar_.keyHandler(key);
        }
        break;
    }
    return true;*/
};

/**
 * Creates the DOM structure for the scrollbar container and its
 * contents, and instantiates the Scrollbar.
 * @private
 */
DRE.views.Housekeeping.prototype.buildDynamicContent_ = function () {

    var container = document.createElement("div"),
        content   = document.createElement("div"),
        callback  = goog.bind(this.populateInfo_, this);

    container.id = "hk-scrollbar-container";
    container.classList.add("scrollbar-container");

    content.id = "hk-scrollbar-content";
    content.classList.add("scrollbar-content");

    container.appendChild(content);

    document.getElementById(this.ids_.PANEL).appendChild(container);

    this.dataProvider_.getHousekeepingInfo(callback);
};

/**
 * Builds the Scrollbar
 * @private
 * @returns {dtv.scroll.Scrollbar} the Scrollbar built
 */
DRE.views.Housekeeping.prototype.buildScrollbar_ = function () {
	var onCallBackDisplay = goog.bind(this.callBackDisplayDone_,this);
    var config = {
        active          : true,
        containerID     : this.ids_.SCROLLBAR_CONTAINER,
        contentID       : this.ids_.SCROLLBAR_CONTENT,
        pixelsPerScroll : 300,
        scrollsPerPage  : 1,
        paddingAdjust   : 20,
		noNeedScrollCB: onCallBackDisplay
    };

    return new dtv.scroll.Scrollbar(config);
};

DRE.views.Housekeeping.prototype.callBackDisplayDone_ = function () {
    //console.log("inside Housekeeping callback function: callBackDisplayDone_");
    // Add the "Done" button
    var done = document.createElement("div");
    done.id = "info-content-done";
    done.classList.add("info-done-button");
    done.appendChild(document.createTextNode("Done"));
    this.done_ = done;

    document.getElementById(this.ids_.PANEL).appendChild(this.done_);
};

DRE.views.Housekeeping.prototype.populateInfo_ = function (items) {
    window.console.log(items);

    var df = document.createDocumentFragment();

    items.services.map(function (value, index, array) {
        return "- " + value;
    }).forEach(function (value, index, array) {
        var p = document.createElement("p");
        p.classList.add("feature-item");
        p.appendChild(document.createTextNode(value));
        df.appendChild(p);
    });

    document.getElementById("hk-summary").appendChild(document.createTextNode(items.info.summary));
    document.getElementById(this.ids_.SCROLLBAR_CONTENT).appendChild(df.cloneNode(true));

    // Now that the data's populated, go ahead and build the scrollbar
    this.scrollbar_ = this.buildScrollbar_();

    if (!!this.scrollbar_) {
        this.focusSomething_();
        this.scrollbar_.onFocus();
    } else {
        throw { error : "scrollbar-fail", message : "The housekeeping scrollbar refused to build!"};
    }

    this.built_ = true;
};

/**
 * @private
 */
DRE.views.Housekeeping.prototype.focusSomething_ = function(){
    if( !this.scrollbarIsVisible_() ){
        this.focused_ = this.done_;
        this.setFocus_(this.done_);
        this.done_.classList.add("active");
    }else{
        this.focused_ = this.scrollbar_;
        this.scrollbar_.onFocus();
        this.setFocus_(this.scrollbar_);
    }
};

/**
 * When the parameter `focusObj' is provided, sets this.focused_ to
 * focusObj, otherwise sets this.focused_ to `null'
 * @private
 * @param {Object=} focusObj  The object that now holds focus (optional)
 */
DRE.views.Housekeeping.prototype.setFocus_ = function (focusObj) {
    if (focusObj !== undefined) {
        this.focused_ = focusObj;
    } else {
        this.focused_ = null;
    }
};
/*
DRE.views.Housekeeping.prototype.doneActive_ = function () {
    this.done_.classList.add("active");
};

DRE.views.Housekeeping.prototype.doneIdle_ = function () {
    this.done_.classList.remove("active");
};*/
