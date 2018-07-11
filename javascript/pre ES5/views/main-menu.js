goog.provide("DRE.views.MainMenu");

goog.require("dtv.list.factory");
goog.require("dtv.list");
goog.require("dtv.io.Remote");

goog.require("dtv.cookie");

/**
 * Main Menu. This is the Main Screen
 * @constructor
 * @param {Object} controller   Reference to the Controller
 * @param {Object} ui           Reference to DRE.UI
 * @param {Object} dataProvider Reference to DRE.DataProvider
 * @param {Object} channel      The PubSub channel to communicate between controller and views
 */
DRE.views.MainMenu = function(controller, ui, dataProvider, channel){
    this.controller_ = controller;
    this.ui_ = ui;
    this.dataProvider_ = dataProvider;
    this.channel_ = channel;
    this.ids_ = CONFIG.IDS.MAIN_MENU;
    this.built_ = false;

    //the interval reference so we can clear it if needed
    // only required if showWeather is true
    if (DRECust.showWeather) {
        this.refreshWeather_ = null;
        this.weatherShown_ = false;
        this.buildWeather_();
    }

    /*console.log(dtv.cookie.get("dre_hist"));
    document.cookie = "WEATHER_KEY=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
    console.log(dtv.cookie.get("WEATHER_KEY"));
    console.log(document.cookie);*/
/*
    dtv.cookie.set("hello", "world");
    console.log(dtv.cookie.get("hello"));*/
    document.cookie = "WEATHER_KEY=; expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/dre/app_loader";
};

/**
 * Displays the main menu
 * @public
 */
DRE.views.MainMenu.prototype.display = function(){
    if(!this.built_){
        this.updateDynamicData_();
        this.buildMenus_();
        this.built_ = true;

        // Check to see if the weather icon is enabled, and setup the
        // weather info to refresh every minute is so
        if (DRECust.showWeather) {
            this.refreshWeather_ = window.setInterval(goog.bind(this.updateWeather_, this), 60000);
        }
    }
    this.ui_.display(CONFIG.BACKGROUNDS.MAIN_MENU, DRECust.backgroundHD, DRECust.backgroundNormal, CONFIG.SCREENS.MAIN_MENU, this.ids_.CONTAINER);
    this.controller_.focusView(this);
    //window.top.postMessage(JSON.stringify({'type':'app','action':'switch'}), DRECust.homePath.substr(0, DRECust.homePath.indexOf('/', 8)));
    this.controller_.postMessage(JSON.stringify({'type':'app','action':'switch'}),DRECust.homePath.substr(0, DRECust.homePath.indexOf('/', 8)));
};

/**
 * Hides the Main Menu
 * @public
 */
DRE.views.MainMenu.prototype.hide = function(){
	UI.hideEl(this.ids_.CONTAINER);
};

/**
 * Disposes the Main Menu.
 */
DRE.views.MainMenu.prototype.dispose = function(){
  window.console.log("Main Menu dipose call");
  //TODO: should we even dispose this since it's the main view?

};

/*DRE.views.MainMenu.prototype.isBonkRequired = function(activeNodeId)
{
    var menuData = this.dataProvider_.getMenuData();
    var leftFirst = menuData["left"]["items"][0].id;
    var leftLast = menuData["left"]["items"][menuData["left"]["items"].length-1].id;

    var rightFirst = menuData["right"]["items"][0].id;
    var rightLast = menuData["right"]["items"][menuData["right"]["items"].length-1].id;

    if(leftFirst == activeNodeId || leftLast == activeNodeId || rightFirst == activeNodeId || rightLast == activeNodeId)
    {
      //bonk here
    }
};*/

/**
 * Handles the key press event when the focus is on the main menu
 * @param  {Object} key
 * @return {!boolean} true if middleware should process the keypress
 *                    further, false otherwise
 */
DRE.views.MainMenu.prototype.keyHandler = function(key){
    var keys = dtv.io.Remote,
        passBackToMW = false;
    switch(key.keyCode){
    case keys.RED:
    case keys.PAGEUP:
    case keys.PAGEDOWN:
        // Properly exit the app
        navigator.clearBackground(0, 0, 1920, 1080);
        VideoSource.setFullScreen();
        navigator.Exit();
        break;
    case keys.UP:
    case keys.DOWN:
        //this.isBonkRequired(this.focused_.getActiveNode());
        this.focused_.keyHandler(key);
        break;
    case keys.SELECT:
        this.focused_.keyHandler(key);
        break;
    case keys.RIGHT:
        if(this.focused_ == this.leftMenu_){
            this.toggleMenuFocus_();
        }
        break;
    case keys.LEFT:
        if(this.focused_ == this.rightMenu_){
            this.toggleMenuFocus_();
        }
        break;
    default:
        // We haven't handled the kep press, so pass through to the
        // next level (middleware)
        passBackToMW = true;
    }
    return passBackToMW;
};

/**
 * Updates the weather, the guest name and the special
 * @private
 */
DRE.views.MainMenu.prototype.updateDynamicData_ = function(){
    this.updateGuest_();
    if (DRECust.showWeather) {
        this.updateWeather_();
    }
    //this.updateSpecials_();
};

/**
 * Builds the weather display
 * @private
 */
DRE.views.MainMenu.prototype.buildWeather_ = function () {
    var icon = document.createElement("div"),
        temp = document.createElement("div"),
        city = document.createElement("div"),
        frag = document.createDocumentFragment(),
        main = document.getElementById(this.ids_.WEATHER);

    icon.id = this.ids_.WEATHER_ICON;
    icon.classList.add("weather-icon");

    temp.id = this.ids_.WEATHER_TEMP;
    temp.classList.add("weather-temp");

    city.id = this.ids_.WEATHER_CITY;
    city.classList.add("weather-city");

    frag.appendChild(icon);
    frag.appendChild(temp);
    frag.appendChild(city);

    main.classList.add("hidden");

    main.appendChild(frag);
};

/**
 * Updates the weather.
 * @private
 */
DRE.views.MainMenu.prototype.updateWeather_ = function(){
    this.dataProvider_.getWeather(DRECust.zipcode,
                                  goog.bind(this.displayWeather_, this));
};

/**
 * Callback function when the weather data is returned from the jsonp request. It updates the weather in the UI
 * @param  {Object} weather Object with "temp" and "icon" properties
 */
DRE.views.MainMenu.prototype.displayWeather_ = function(weather) {
    var welcomeDiv         = document.getElementById(this.ids_.WELCOME),
        weatherDiv         = document.getElementById(this.ids_.WEATHER),
        weatherIcon        = document.getElementById(this.ids_.WEATHER_ICON),
        weatherTemperature = document.getElementById(this.ids_.WEATHER_TEMP),
        weatherLocation    = document.getElementById(this.ids_.WEATHER_CITY);

    if (!weather && !this.weatherShown_ || !DRECust.showWeather) {
        weatherDiv.classList.add("hidden");
        welcomeDiv.classList.add("welcome-left");
    } else {
        if (!!weather) {
            var temp = "" + weather["temp"] + " °F",
                city = weather["city"];

            //set the icon
            weatherIcon.style.backgroundImage = "url('assets/images/weather/" + weather["icon"]  + ".png')";

            //set the temperature
            weatherTemperature.innerHTML = temp;

            //set the location
            weatherLocation.innerHTML = city;

            if (DRECust.showWeather && weatherDiv.classList.contains("hidden")) {
                weatherDiv.classList.remove("hidden");
                welcomeDiv.classList.remove("welcome-left");
                this.weatherShown_ = true;
            }
        }
    }
};

/**
 * Updates the name of the guest
 * @private
 */
DRE.views.MainMenu.prototype.updateGuest_ = function(){
    var displayGuest = function (guestName, room) {
		var wMsg = DRECust.welcomeMessage;

		if ( guestName ) {
			wMsg = wMsg.replace("%guest%", (guestName['firstName']) ? guestName['firstName'] : "");
			wMsg = wMsg.replace("%fn%", (guestName['firstName']) ? guestName['firstName'] : "");
			wMsg = wMsg.replace("%ln%", (guestName['lastName'])  ? guestName['lastName'] : "");
			wMsg = wMsg.replace("%rm%", room ? room : "");
		} else {
			wMsg = DRECust.altWelcomeMessage;
			wMsg = wMsg.replace("%rm%", room ? room : "");
		}
        UI.html(this.ids_.GUEST, wMsg);

        var regex = /^[0-9a-z_-]+$/i;
        var roomNumMsg;
        if (room && room !== "" && regex.test(room)) {
             roomNumMsg = "Room " + room;
        } else {
            roomNumMsg = "";
        }
        UI.html(this.ids_.ROOM_NUMBER, roomNumMsg);
    };

    this.dataProvider_.getGuest(goog.bind(displayGuest, this));
};

/**
 * Updates the specials that go below the welcome message
 * @private
 */
DRE.views.MainMenu.prototype.updateSpecials_ = function(){
	var specials = this.dataProvider_.getSpecials();
	UI.html(this.ids_.SPECIALS, specials);
};

/**
 * Builds both left and right menu and sets the focus to the left menu
 * @private
 */
DRE.views.MainMenu.prototype.buildMenus_ = function(){
  var menuData = this.dataProvider_.getMenuData();
  var leftMenu = menuData["left"];
  var rightMenu = menuData["right"];

  this.leftMenu_ = this.buildMenu_(leftMenu["domId"],
                                   leftMenu["items"],
                                   leftMenu["class"]);

  this.rightMenu_ = this.buildMenu_(rightMenu["domId"],
                                    rightMenu["items"],
                                    rightMenu["class"]);

  this.leftMenu_.onFocus();

  this.focused_ = this.leftMenu_;

};

/**
 * Generic method to build a menu, this gets called to build both left and right menu
 * @param  {string} domId        The Dom ID of the menu
 * @param  {Array} items        Array of objects that contain "id" and "value" to build the menu items
 * @param  {string} defaultClass The CSS Class to apply to the whole menu
 * @return {(dtv.list.BasicList|boolean)}  The created list
 */
DRE.views.MainMenu.prototype.buildMenu_ = function(domId, items, defaultClass){
	var action = goog.bind(this.menuItemSelected_, this);
	var listConfig = {
        "domId" : domId,
        "action" : action,
        "items": [],
        "defaults" : {
            "active": false,
            "theme" : {
                "defaultClass" : defaultClass,
                "listItem" : {
                    "defaultClass" : "main-menuitem",
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
      listConfig["items"].push(listItem);
    }

    return dtv.list.factory.createList("awesome", listConfig);
};

/**
 * Callback function when a menu item is selected.
 * Calls the right function depending on which item was selected
 * @private
 * @param  {dtv.list.Item} item The Item that was selected
 */
DRE.views.MainMenu.prototype.menuItemSelected_ = function(item){
    var menuItemId = item.getId();
    var message = {
	'type' : 'app',
	'action' : 'load',
	'url' : DRECust.layoutSpec[menuItemId].url,
	'message' : DRECust.layoutSpec[menuItemId]['linkText'] + ' is loading...'
    };
    //tell controller not to go to fullscreen on exit:
    this.controller_.dontclear();
    //window.top.postMessage(JSON.stringify(message), DRECust.homePath.substr(0, DRECust.homePath.indexOf('/', 8)) );
    this.controller_.postMessage(JSON.stringify(message),DRECust.homePath.substr(0, DRECust.homePath.indexOf('/', 8)),false);
};

/**
 * Toggles the menu focus from left to right and vice versa
 * @private
 */
DRE.views.MainMenu.prototype.toggleMenuFocus_ = function(){

  this.focused_.lostFocus();
  if(this.focused_ == this.rightMenu_){
    this.focused_ = this.leftMenu_;
  }else{
    this.focused_ = this.rightMenu_;
  }

  this.focused_.onFocus();

};

/**
 * Hides the app and goes fullscreen. Same as if the red circle button was pressed
 * @private
 */
DRE.views.MainMenu.prototype.liveTV_ = function(){
  this.controller_.hideApp();
};

/**
 * Brings up the DIRECTV  guide
 * So far there is no way to invoke the guide.
 * @private
 */
DRE.views.MainMenu.prototype.programGuide_ = function(){

  var url = CONFIG.STB_IP +  "/tv/goToUIScreen";


  var crossOriginPost = function(url, formData){

    var form = document.createElement("form");
    form.enctype = "multipart/form-data";
    form.id = "shef-form";
    form.action = url;
    form.method = "POST";

    for(var prop in formData){

      var input = document.createElement("input");
      input.type = "hidden";
      input.name = prop;
      input.value = formData[prop];
      form.appendChild(input);
    }

    document.body.appendChild(form);
    form.submit();
  };

  crossOriginPost(url, {
    "screen": "8_9999",
    "contentId": "1"
  });

};

/**
 * Brings up the ScoreGuide App
 * @private
 */
DRE.views.MainMenu.prototype.scoreGuide_ = function(){
  window.location = CONFIG.URLS.SCORE_GUIDE;

};

/**
 * Brings up the Weather App
 * @private
 */
DRE.views.MainMenu.prototype.weather_ = function(){
  window.location = CONFIG.URLS.WEATHER;

};

/**
 * Opens the Hotel Info Screen.
 * @private
 */
DRE.views.MainMenu.prototype.hotelInfo_ = function(){
  this.hide();
  this.controller_.displayView(CONFIG.VIEWS.HOTEL_INFO);
};

DRE.views.MainMenu.prototype.housekeeping_ = function () {
    this.hide();
    this.controller_.displayView(CONFIG.VIEWS.HOUSEKEEPING);
};

/**
 * Room Service not implemented yet
 * @private
 */
DRE.views.MainMenu.prototype.roomService_ = function(){
  window.console.log("Room Service Not Implemented Yet");

};

/**
 * Rewards not implemented yet
 * @private
 */
DRE.views.MainMenu.prototype.rewards_ = function(){
  window.console.log("Rewards Not Implemented Yet");

};

/**
 * Checkout not implemented yet
 * @private
 */
DRE.views.MainMenu.prototype.checkout_ = function(){
  window.console.log("Checkout Not Implemented Yet");

};
