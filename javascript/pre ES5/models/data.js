goog.provide("DRE.DataProvider");

goog.require("dtv.jsonP");
goog.require("dtv.ajax");

/**
 * @constructor
 */
DRE.DataProvider = function(controller, channel){
	this.controller_ = controller;
	this.channel_ = channel;
};

/**
 * Get the weather data of a zipcode
 * @param zipcode
 * @param cb - the function to be called back once the data is ready
 * @returns an associate array which has {"icon", "temp"}
 */
DRE.DataProvider.prototype.getWeather = function(zipcode, cb){

    var resolveIcon = goog.bind(this.resolveIcon_, this),
        weatherURL  = this.resolveURL_(zipcode),
        locationURL = this.resolveURL_(zipcode, "loc"),
        // headCheck = new XMLHttpRequest(),
        weatherDead = function () {
            window.console.log("There was an issue loading the weather");
            cb(false);
        },
        outputWeather = goog.bind(function (response) {
            var data = response.feed,
                weather = {
                    "icon" : data["wxIcon"],
                    "temp" : data["temp"]
                };
            if (!!DRECust.cityName) {
                var w = weather;
                w["city"] =  DRECust.cityName + ", " + DRECust.stateAbbrev;
                cb(w);
            } else {
                this.request_(locationURL,
                              function (res) {
                                  var data = res.feed;
                                  var w = weather;
                                  w["city"] = data["city"] + ", " + data["state"];
                                  cb(w);
                              }, weatherDead);
            }
        }, this);

    this.request_(weatherURL, outputWeather, weatherDead);
};

/**
 * Combine ZIPCODE and COMMAND to create the request URL for weather
 * @param {string} zipcode the zipcode to use for the weather location
 * @param {string=} command optional argument for the URL command; if not provided, defaults to "obs_hirad"
 * @returns {string} fully-formed request URL
 */
DRE.DataProvider.prototype.resolveURL_ = function(zipcode, command){
    return CONFIG.WEATHER_DATA_URL
        .replace("%COMMAND%", (!!command) ? command : "obs_hirad")
        .replace("%ZIPCODE%", zipcode.toString()) +
        "?key=" + CONFIG.WEATHER_API_KEY;
};

/**
 * Resolve the 3rd party's icon to DirecTV icon
 * @param icon
 * @returns DirecTV's icon
 */
DRE.DataProvider.prototype.resolveIcon_ = function(icon) {

	//TODO: need to get the mapping file from either WeatherNation or Mario
	var iconNum = CONFIG.ICONS[icon];

	if(iconNum == null) {
		iconNum = CONFIG.ICONS[CONFIG.DEFAULT.ICON];
	}
	return iconNum;
};


/**
 * @description make a jsonp request
 * @param {!string} url the URL of the request
 * @param {!function((Object|boolean))} ready callback to call when the request returns
 * @param {function()=} dead optional function to call if the request fails
 */
DRE.DataProvider.prototype.request_ = function(url, ready, dead){
    dtv.jsonP({
        el : null,
        url : url,
        'ready' : ready,
        dead : (!!dead) ? dead : function(){window.console.log('Could not retrieve data.');}
    });
};

/**
 * Gets the guest name.
 * @public
 * @param {function((string|boolean), (string|boolean))} cb a callback function that will take either the guest's name or the boolean "false" value
*/
DRE.DataProvider.prototype.getGuest = function(cb){
    // make a call to the PMS to retrieve the guest list, then take
    // the first name off the top

    var guestURL    = CONFIG.PMS_URL + "/sbbmgr/pmsi/get_guest_info?rid=" + this.controller_.rid_,
        xhqr        = new XMLHttpRequest(),
        xhqrTimeout = setTimeout(function () {
            window.console.log("### [TIMEOUT] Guest name request timed out");
            xhqr.abort();
        }, 5000);

		console.log("### [XCHECK] Performing request on: " + guestURL);

    xhqr.open("GET", guestURL);

    xhqr.addEventListener("readystatechange", function (evt) {
        window.console.log("### [XCHECK] Guest name retrieval ready state: " + this.readyState);
        if (this.readyState === 4) {
            window.clearTimeout(xhqrTimeout);
            if (this.status === 200) {
                var response = JSON.parse(this.responseText);
                window.console.log("### [INFO] Retrieved guest info: " + this.responseText);
								cb((response["status"] === "success") ? response["guests"][0] : false, response["room"] ? response["room"] : false);
            } else {
                window.console.log("### [FAIL] There was an error with the response: " +
                                   this.responseText);
                cb(false);
            }
        }
    });

    xhqr.send();
};

/**
 * Sends a room number to the mcs and refreshed the currently displayed room number
 * @public
 * @param {string} roomNumber the room number to be sent to the mcs
 * @param {function()} callback function to refresh displayed room number
 */
DRE.DataProvider.prototype.sendRoomNumber = function(roomNumber, refreshCallBack){
    var postRoomUrl = CONFIG.PMS_URL + "/sbbmgr/pmsi/update_room?rid=" + this.controller_.rid_ + "&room=" + roomNumber;
    var xhr = new XMLHttpRequest();

    console.log("### [XCHECK] URL: " + postRoomUrl);

    xhr.open("GET", postRoomUrl);

    xhr.timeout = 5000;

    xhr.onload = function(event) {
        console.log("### [INFO] URL " + postRoomUrl + " resolved successfully with http status:" + this.status);
        if (this.status === 200) {
            console.log("### [INFO] Response received: " + this.responseText);
            if(refreshCallBack)
                refreshCallBack();
        }
    };

    xhr.ontimeout = function(event) {
        window.console.log("### [TIMEOUT] send room number request timed out");
        xhr.abort();
    };

    xhr.send();
};

/**
 * Gets the specials that go below the welcome message in the main menu
 * @public
 * @return {string} String representing the specials
 */
DRE.DataProvider.prototype.getSpecials = function(){
	return "Check out our spa specials.";
};

/**
 * Gets the Main Menu Item Data.
 * @public
 * @return {Object} Menu Item Data that has both left and right menu items, with their dom ids and the CSS class to apply to them
 */
DRE.DataProvider.prototype.getMenuData = function() {
    var leftMenuItems = [],
        rightMenuItems = [];

    for (var app in DRECust.layoutSpec) {
        if (app !== "layout") {
            var menu = (/_left$/.test(app)) ? leftMenuItems : rightMenuItems;
            // Push the current app specs onto the correct menu
            menu.push(this.generateMenuItem_(app,
                                             DRECust.layoutSpec[app]));
        }
    }

    return {
	"left": {
	    "items": leftMenuItems,
	    "domId": "mm-left-menu",
	    "class": "menu"
	},
	"right": {
	    "items": rightMenuItems,
	    "domId": "mm-right-menu",
	    "class": "menu"
	}
    };

};

/**
 * Generates a menu item from a customization spec
 * @param {!string}  id   the id of menu button being created
 * @param {!Object}  spec
 * @returns {!Object} an object with fields "url" and "html"
 */
DRE.DataProvider.prototype.generateMenuItem_ = function(id, spec) {
    return { "id" : id,
             "value" : "<div class=\"icon " + spec["iconClass"] + "\"></div><div class=\"label\"><div class=\"label-holder\"><div class=\"label-text\">" + spec["linkText"] + "</div></div></div>" };
};

DRE.DataProvider.prototype.getHotelInfo = function(callback){
	var that = this;
	var onDataRetrieved = dtv.ajax(function(data){

		var services = data["services"];
		var items = [];
		var service = {};
		for(var i=0; i<services.length; i++){
			service = services[i];

			items.push({
				"id": "hi-item" + i,
				"value": service["menu_item"],
				"content": that.buildHotelInfoItem_(service)
			});
		}

                // HACK HACK add a "Done" button to the hotel info menu
                items.push({
                    "id" : "hi-item-done",
                    "value" : "Done",
                    "content" : ""
                });

		callback(items);
	}, CONFIG.HOTEL_INFO_URL);

};


DRE.DataProvider.prototype.buildHotelInfoItem_ = function(itemInfo){
	var content = "";

	//banner
	var backgroundImg = "url('assets/images/hotel-info/" + itemInfo["banner_img"]  + "')";
	content += '<div class="info-banner" style="background-image: ' + backgroundImg + '"></div>';

	//details
	content += '<p class="info-details">' + itemInfo["details"] + '</p>';

	content += '<p class="info-features">Features:</p>';
	content += '<p class="features-list">';

	var features = itemInfo["summary"];

	for(var i=0; i<features.length; i++){
		content += '<p class="feature-item" > - ' + features[i] + '</p>';
	}

	var createIfExists = function(key, value){
		if(value && value.length && value.length > 1){
			return '<p class="info-keyvalue"><span class="info-key">' + key + '</span><span class="info-value">' + value + '</span></p>';
		}else{
			return "";
		}
	};

	content += createIfExists("Hours: ", itemInfo["hours"]);
	content += createIfExists("Phone: ", itemInfo["phone"]);
	content += createIfExists("Location: ", itemInfo["location"]);

	return content;

};


/**
 * Gets the default message to display on the hotel info landing page for when no menu item is currently selected.
 * @return {string} The String representing the DOM Structure to show when no menu item is selected
 */
DRE.DataProvider.prototype.getDefaultHotelInfoData = function(){
  //TODO: build it using the same function as menu items and change it to asynchronus call
  return '<div class="scrollbar-container"><div class="info-banner" style="background-image: url(\'assets/images/hotel-info/nycex_explorehotel.jpg\')"></div><p class="info-details">CONRAD South Bay</p><p class="info-features">Features:</p><p class="features-list"><p class="feature-item" > - This premier Los Angeles luxury hotel offers distinctive details from its Art Deco past</p><p class="feature-item" > - Expertly edited amenities and stunning ocean views.</p><p class="feature-item" > - The hotel\'s South Bay locale and subtly refined LA suites make it an ideal pied-à-terre for visiting the Venice Boardwalk or Disney Concert Hall.</p><p class="feature-item" > - A Beaux Arts-style Grand Salon replete with chandeliers, murals and private entrance creates an indulgent setting for a New York wedding celebration.</p><p class="info-keyvalue"><span class="info-key">Hours: </span><span class="info-value">Open 24hrs</span></p><p class="info-keyvalue"><span class="info-key">Phone: </span><span class="info-value">(310) 555-0300</span></p><p class="info-keyvalue"><span class="info-key">Location: </span><span class="info-value">2300 Ocean Drive  Manhattan Beach  California  90266  USA </span></p></div>';
};


DRE.DataProvider.prototype.getHousekeepingInfo = function (callback) {
    var that = this;
    var onDataRetrieved = dtv.ajax(function (data) {
        window.console.log(data);
        var info     = data["main_info"],
            services = data["services"];

        callback({ info     : info,
                   services : services });
    }, CONFIG.HOUSEKEEPING_URL);
};
