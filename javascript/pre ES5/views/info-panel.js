goog.provide("DRE.views.InfoPanel");

goog.require("dtv.io.Remote");
//goog.require("dtv.scroll.Scrollbar");
goog.require("dtv.scroll.factory");

/**
 * Info Panel is the generic panel that describes a Hotel's item of interest.
 * @constructor
 * @param {Object} controller   Reference to the Controller
 * @param {Object} ui           Reference to DRE.UI
 * @param {Object} dataProvider Reference to DRE.DataProvider
 * @param {Object} channel      The PubSub channel to communicate between controller and views
 */
DRE.views.InfoPanel = function(controller, ui, dataProvider, channel){
    this.controller_ = controller;
    this.ui_ = ui;
    this.dataProvider_ = dataProvider;
    this.channel_ = channel;
    this.ids_ = CONFIG.IDS.INFO_PANEL;
    this.built_ = false;
    this.scrollbar_ = null;
    this.done_ = null;

    this.focused_ = null;
    //the content to display
    this.content_ = "";
};

/**
 * Displays the panel
 * @public
 */
DRE.views.InfoPanel.prototype.display = function(){
    //this.ui_.display(CONFIG.BACKGROUNDS.HOTEL_INFO, CONFIG.SCREENS.HOTEL_INFO, this.ids_.CONTAINER);
    
    this.controller_.focusView(this);

    if(!this.built_){
        
        this.buildDynamicContent_();

        this.built_ = true;
    }

    this.focusSomething_();

    UI.showEl(this.ids_.SCROLLBAR_CONTENT);
};

/**
 * Hides the contents of the scrollbar
 * @public
 */
DRE.views.InfoPanel.prototype.hide = function(){
	UI.hideEl(this.ids_.SCROLLBAR_CONTAINER);

};

/**
 * Disposes the info panel
 * @public
 */
DRE.views.InfoPanel.prototype.dispose = function(){
    this.scrollbar_ = null;
    this.content_ = "";
    this.built_ = false;
    this.done_ = null;
};

/**
 * Handles the key press event when the focus is on Hotel Info Panel
 * @public
 * @param  {Object} key 
 * @return {boolean}     true if the handling was done satisfactory.
 */
DRE.views.InfoPanel.prototype.keyHandler = function(key){
    var keys = dtv.io.Remote;
    //No Scrollbar (Just a Done button)
    if(!this.scrollbarIsVisible_() )
    {
        if(key.keyCode==keys.LEFT || key.keyCode==keys.SELECT){
            //this.doneIdle_();//remove 'active' from class list
            this.setFocus_();
            this.hide();//hide InfoPanel
            this.controller_.displayView(CONFIG.VIEWS.HOTEL_INFO);
        }
        return true;
    }
    else{//Just A Scrollbar:
        switch(key.keyCode){
        case keys.LEFT://Left 
            this.scrollbar_.lostFocus();
            this.hide();//hide InfoPanel
            this.controller_.displayView(CONFIG.VIEWS.HOTEL_INFO);
            this.setFocus_();
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
    }
    /*
    switch(key.keyCode){
    case keys.LEFT:
        if (this.focused_ === this.scrollbar_) {
            this.scrollbar_.lostFocus();
            this.hide();
            this.controller_.displayView(CONFIG.VIEWS.HOTEL_INFO);
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
            window.console.log("We should be switching focus now");
            this.scrollbar_.lostFocus();
            this.setFocus_(this.done_);
            this.doneActive_();
            break;
        }
    case keys.UP:
        window.console.log("Moving up in the world!");
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
            this.controller_.displayView(CONFIG.VIEWS.HOTEL_INFO);
        } else if (this.focused_ === this.scrollbar_) {
            this.scrollbar_.keyHandler(key);
        }
        break;
	}*/
};

/**
 * Sets the content that goes inside the scrollbar
 * @param {string} content The Content to go inside the scrollbar
 */
DRE.views.InfoPanel.prototype.setContent = function(content){
  this.content_ = content;
};

/**
 * Creates the DOM structure for the scrollbar container, content and instantiates the Scrollbar.
 * @private
 */
DRE.views.InfoPanel.prototype.buildDynamicContent_ = function(){

    var elements = '<div id="hi-scrollbar-container" class="scrollbar-container"><div id="hi-scrollbar-content" class="scrollbar-content"></div>';
    UI.html(this.ids_.PANEL, elements);
    UI.html(this.ids_.SCROLLBAR_CONTENT, this.content_);
    this.scrollbar_ = this.buildScrollbar_();
    this.focusSomething_();
};

/**
  * @return {boolean}
  * returns true if scrollbar is visible
  * returns false if scrollbar is hidden (and done/okay is visible)
  */
DRE.views.InfoPanel.prototype.scrollbarIsVisible_ = function(){
    return ((!this.scrollbar_.track.classList.contains("hidden")) ? true : false);
};

/**
 * @private
 */
DRE.views.InfoPanel.prototype.focusSomething_ = function(){
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
 * Builds the Scrollbar
 * @return {Object|null} The dtv.Scrollar built
 */
DRE.views.InfoPanel.prototype.buildScrollbar_ = function(){
    /*Using goog.bind will make it so inside the callBackDisplayDone_() method
     *accessing 'this' accesses 'DRE.views.InfoPanel' 
     *otherwise 'this' will be 'DRE.scroll.Scrollbar'
     */
    var onCallBackDisplay = goog.bind(this.callBackDisplayDone_,this),
        config = {
            active: true,
            containerID : this.ids_.SCROLLBAR_CONTAINER,
            contentID : this.ids_.SCROLLBAR_CONTENT,
            pixelsPerScroll: 300,
            scrollsPerPage : 1,
            paddingAdjust: 20,
            noNeedScrollCB: onCallBackDisplay 
        };
    return dtv.scroll.factory.createScrollbar(config);
};

DRE.views.InfoPanel.prototype.callBackDisplayDone_ = function () {
    //console.log("inside InfoPanel callback function: callBackDisplayDone_");
    // Add the "Done" button
    
    //add var done then attach to this.done_ this way not using heap memory.
    var done = document.createElement("div");
    done.id = "info-content-done";
    done.classList.add("info-done-button");
    done.appendChild(document.createTextNode("Okay"));
    this.done_ = done;

    document.getElementById(this.ids_.PANEL).appendChild(this.done_);
};

/**
 * @param {Object=} focusObj
 */
 //*
DRE.views.InfoPanel.prototype.setFocus_ = function (focusObj) {
	if( focusObj && focusObj !== null && focusObj !== undefined ){
		this.focused_ = focusObj;
    } else {
        this.focused_ = null;
    }
};
/*
DRE.views.InfoPanel.prototype.doneActive_ = function () {
    this.done_.classList.add("active");
};
 
DRE.views.InfoPanel.prototype.doneIdle_ = function () {
    this.done_.classList.remove("active");
};
*/
