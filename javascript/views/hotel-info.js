goog.provide("DRE.views.HotelInfo");

goog.require("dtv.list.factory");
goog.require("dtv.io.Remote");

/**
 * Hotel Info. This is the Screen with the left menu and the info panel in it
 * @constructor
 * @param {Object} controller   Reference to the Controller
 * @param {Object} ui           Reference to DRE.UI
 * @param {Object} dataProvider Reference to DRE.DataProvider
 * @param {Object} channel      The PubSub channel to communicate between controller and views
 */
DRE.views.HotelInfo = function(controller, ui, dataProvider, channel){
  this.controller_ = controller;
  this.ui_ = ui;
  this.dataProvider_ = dataProvider;
  this.channel_ = channel;
  this.ids_ = CONFIG.IDS.HOTEL_INFO;
  this.built_ = false;
  this.menu_ = null;
};

/**
 * Displays the Hotel Info Screen
 * @public
 */
DRE.views.HotelInfo.prototype.display = function(){
  this.ui_.display(CONFIG.BACKGROUNDS.HOTEL_INFO, DRECust.backgroundHD, DRECust.backgroundNormal, CONFIG.SCREENS.HOTEL_INFO, this.ids_.CONTAINER);
  this.controller_.focusView(this);

  if(!this.built_){
    this.buildDynamicData_();
    this.built_ = true;
  }

  if(this.menu_){
    this.menu_.onFocus();
    var selectedId = this.menu_.getSelectedNode();
    if(selectedId){
      UI.removeClass(selectedId, "selected");
    }

  }

  //when we come back from having the focus on the info panel's scrollbar, we must remove the dimmed class
  UI.removeClass(this.ids_.MENU, "dimmed");

  //So long as the Menu has focus, we must display the initial panel to follow DirecTV's fullscreen guidelines
  this.displayInitialPanel_();

};

/**
 * Removes the focus from the menu and applies the dimmed class to it
 * This gets called when a menu item is selected, and in case the default message is navigable, when the user presses RIGHT
 * @public
 */
DRE.views.HotelInfo.prototype.lostFocus = function(){
  this.menu_.lostFocus();
  UI.addClass(this.ids_.MENU, "dimmed");

};

/**
 * Hides the Hotel Info Screen
 * @public
 */
DRE.views.HotelInfo.prototype.hide = function(){
  UI.hideEl(this.ids_.CONTAINER);
  if(this.menu_){
    this.menu_.lostFocus();
  }


};

/**
 * Disposes the Hotel Info Screen
 * @public
 */
DRE.views.HotelInfo.prototype.dispose = function(){
  window.console.log("Hotel Info dipose call");
  //TODO: dispose routine
};

/**
 * Gets the Hotel Info Menu Items for the left menu.
 * @return {Array} Array of Objects that have "id" and "value" to create the menu
 */
DRE.views.HotelInfo.prototype.getHotelInfoItems = function(){
  //TODO: get the actual stuff from config json file
  this.getHotelInfoData();
  var items = [];
  items.push({"id": "hi-item0", "value": "Dining"});
  items.push({"id": "hi-item1", "value": "Fitness"});
  items.push({"id": "hi-item2", "value": "Spa"});
  items.push({"id": "hi-item3", "value": "Rewards"});
  items.push({"id": "hi-item4", "value": "Pool"});
  items.push({"id": "hi-item5", "value": "Tours"});

  // return items;
};

/**
 * Handles the key press event when the focus is on Hotel Info Screen
 * @public
 * @param  {Object} key
 * @return {Boolean}     true if the handling was done satisfactory.
 */
DRE.views.HotelInfo.prototype.keyHandler = function(key){
  var keys = dtv.io.Remote;
  switch(key.keyCode){
    case keys.LEFT:
      this.hide();
      this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
      break;
    case keys.UP:
    case keys.DOWN:
    case keys.SELECT:
      // HACK HACK if the "Done" item is selected, return to the main menu
      if (key.keyCode === keys.SELECT &&
          this.menu_.activeNode_.domId_ === "hi-item-done") {
          this.hide();
          this.controller_.displayView(CONFIG.VIEWS.MAIN_MENU);
          navigator.gc();
      } else {
          this.menu_.keyHandler(key);
      }
      break;
  }
  return true;
};

DRE.views.HotelInfo.prototype.buildDynamicData_ = function(){
  var callback = goog.bind(this.buildMenu_, this);
  this.dataProvider_.getHotelInfo(callback);

};


/**
 * Builds the left menu
 * @param  {Array} items Array of objects with "id" and "value" to build the menu
 * @return {dtv.List}       The list built
 */
DRE.views.HotelInfo.prototype.buildMenu_ = function(items){
  var action = goog.bind(this.menuItemSelected_, this);
  var listConfig = {
        "domId" : this.ids_.MENU,
        "action" : action,
        "items": [],
        "defaults" : {
            "active": false,
            "theme" : {
                "defaultClass" : "fullscreen-menu",
                "listItem" : {
                    "defaultClass" : "hotel-info-menuitem",
                    "activeClass" : "active",
                    "selectedClass" : "selected"
                }
            }
        },
        'orientation' : 'vertical'
    };
    var length = items.length;
    var listItem = {};
    var item= {};
    for(var i=0; i< length; i++){
      item = items[i];
      listItem = dtv.list.factory.createListItem("create",
        {
         "id": item["id"],
         "value": item["value"]
        });

      listItem.content = item["content"];
      listConfig["items"].push(listItem);
    }

    this.menu_ =  dtv.list.factory.createList("awesome", listConfig);
    this.menu_.onFocus();
};

/**
 * Callback function when a menu item is selected.
 * @private
 * @param  {ListItem} item The ListItem that was selected
 */
DRE.views.HotelInfo.prototype.menuItemSelected_ = function(item){
  window.console.log("Hotel Info Menu Item Selected: " + item.getId());

  this.controller_.disposeView(CONFIG.VIEWS.INFO_PANEL);

  var infoPanelView = this.controller_.getView(CONFIG.VIEWS.INFO_PANEL);

  var content = item.listItem.content;

  infoPanelView.setContent(content);
  infoPanelView.display();

  this.lostFocus();
};

/**
 * Displays the initial panel when there is no menu item selected.
 * This initial panel needs to be displayed when coming back from the panel to follow DirecTV's fullscreen guidelines.
 */
DRE.views.HotelInfo.prototype.displayInitialPanel_ = function(){

  var content = this.dataProvider_.getDefaultHotelInfoData();
  UI.html(this.ids_.PANEL, content);

};
