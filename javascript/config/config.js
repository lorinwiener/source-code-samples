/** @namespace */
goog.provide('CONFIG');
goog.provide('CONFIG.URL');

/** @enum {number} */
CONFIG.VIEWS = {
  MAIN_MENU: 0,
  HOTEL_INFO: 1,
  ROOM_SERVICE: 2,
  REWARDS: 3,
  CHECKOUT: 4,
  INFO_PANEL: 5,
  HOUSEKEEPING: 6,
  ROOM_NUMBER_ENTRY: 7
};

CONFIG.WEATHER_API_KEY  = "6d3cca3b-7e8d-4f0d-b9c2-80f5da45a475";
// CONFIG.WEATHER_DATA_URL = "//api.aerisapi.com/observations/[ZIPCODE]?client_id=kGiR8AXzBsrjY8xeu4lXW&client_secret=LbGTZjZ78qHBwrZ6S5RmJKmregmDXa1kD0Kdf2bU";
CONFIG.WEATHER_DATA_URL = "http://wxdata.weather.com/wxdata/%COMMAND%/%ZIPCODE%.js";

CONFIG.HOTEL_INFO_URL = "assets/json/hotel-info.json";

CONFIG.HOUSEKEEPING_URL = "assets/json/housekeeping.json";

//if running from STB,

//if testing on Chrome you have to change this IP to your STB's IP.
CONFIG.STB_IP = navigator.userAgent.indexOf('Chrome') !== -1? "http://192.168.1.102:8080": "http://127.0.0.1:8080";
CONFIG.PMS_URL = "https://172.16.1.11:5559";

CONFIG.DEFAULT = {
  ZIPCODE : 90266,
  ICON : "Not Available"
};

CONFIG.IDS = {};

CONFIG.IDS.MAIN_MENU = {
	WELCOME: "mm-welcome",
	CONTAINER: "MainMenuScreen",
	WEATHER: "mm-weather-holder",
	WEATHER_ICON: "mm-weather-icon",
	WEATHER_TEMP: "mm-weather-temp",
  WEATHER_CITY: "mm-weather-city",
	GUEST: "mm-guest",
	SPECIALS: "mm-specials",
	LEFT_MENU: "mm-left-menu",
	RIGHT_MENU: "mm-right-menu",
	ITEMS: {
		LIVE_TV: "mm-item0",
		PROGRAM_GUIDE: "mm-item1",
		SCORE_GUIDE: "mm-item2",
		HOTEL_INFO: "mm-item3",
		HOUSEKEEPING: "mm-item4",
		CHECKOUT: "mm-item5"
	},
	ROOM_NUMBER: "mm-room-number"
};

CONFIG.IDS.HOTEL_INFO = {
	CONTAINER: "HotelInfoScreen",
	MENU: "hi-menu",
	PANEL: "hi-info-panel"
};

CONFIG.IDS.INFO_PANEL = {
	CONTAINER: "hi-scrollbar-container",
	PANEL: "hi-info-panel",
	SCROLLBAR_CONTAINER: "hi-scrollbar-container",
	SCROLLBAR_CONTENT: "hi-scrollbar-content"
};

CONFIG.IDS.ROOM_SERVICE = {
	CONTAINER: "RoomServiceScreen"

};

CONFIG.IDS.REWARDS = {
	CONTAINER: "RewardsScreen"
};

CONFIG.IDS.CHECKOUT = {
	CONTAINER: "CheckoutScreen"

};

CONFIG.IDS.HOUSEKEEPING = {
	CONTAINER: "HousekeepingScreen",
	PANEL: "hk-info-panel",
	SCROLLBAR_CONTAINER: "hk-scrollbar-container",
	SCROLLBAR_CONTENT: "hk-scrollbar-content"
};

CONFIG.IDS.ROOM_NUMBER_ENTRY = {
	CONTAINER: "RoomNumberEntryScreen",
	KEYBOARD_CONTAINER: "rne-keyboard-container",
	KEYBOARD: "rne-keyboard",
	INSTRUCS: "rne-instrucs",
	OK_CANCEL_MENU: "rne-ok-cancel-menu"
};

CONFIG.SCREENS = {
	MAIN_MENU: "MainMenuScreen",
	HOTEL_INFO: "HotelInfoScreen",
	ROOM_SERVICE: "RoomServiceScreen",
	REWARDS: "RewardsScreen",
	CHECKOUT: "CheckoutScreen",
	HOUSEKEEPING: "HousekeepingScreen",
	ROOM_NUMBER_ENTRY: "RoomNumberEntryScreen"
};

CONFIG.BACKGROUNDS = {
	MAIN_MENU: "dre_bkg",
	HOTEL_INFO: "dre_bkg",
	HOUSEKEEPING: "dre_bkg"
};

//For testing on CE
CONFIG.URLS = {
	SCORE_GUIDE: "https://int-iw.dtvce.com:8443/widgets/scoreguide2.0/index.html?returnURL=" + window.location,
	//WEATHER: "https://int-iw.dtvce.com:8443/widgets/weather2.0/twc/index.html?returnURL=" + window.location
	WEATHER: "http://10.8.111.7:8091/tv_apps_weather/index.html?returnURL=" + window.location + "&zipcode=" + 91007 //test server
};


CONFIG.ICONS = {

	"Clear" :  31,
	"Cloudy" : 26,
	//"Cloudy" : 27,
	"Cloudy with Blowing Snow" : 43,
	"Cloudy with Drizzle" : 9,
	"Cloudy with Hazy" : 19,
	"Cloudy with Heavy Drizzle" : 9,
	"Cloudy with Heavy Rain" : 12,
	"Cloudy with Heavy Snow" : 42,
	"Cloudy with Light Drizzle" : 9,
	"Cloudy with Light Rain" : 12,
	"Cloudy with Light Snow" : 42,
	"Cloudy with Light Snow Showers" : 14,
	"Cloudy with Mist and Fog" : 20,
	"Cloudy with Overcast and Windy" : 26,
	"Cloudy with Rain" : 12,
	"Cloudy with Snow" : 42,
	"Cloudy/Windy" : 26,
	//"Fair" : 33,
	"Fair" : 34,
	"Fair/Windy" : 34,
	"Light Snow" : 14,
	"Mostly Clear" : 29,
	//"Mostly Cloudy" : 27,
	//"Mostly Cloudy" : 28,
	"Mostly Cloudy" : 34,
	"Mostly Cloudy with Hazy" : 19,
	"Mostly Cloudy with Light Rain" : 12,
	"Mostly Cloudy with Light Snow" : 14,
	"Mostly Cloudy with Mist and Fog" : 20,
	"Mostly Cloudy with Nearby" : 0,
	"Mostly Cloudy with Rain" : 12,
	"Mostly Cloudy with Scattered Snow" : 41,
	"Mostly Cloudy/Windy" : 28,
	"Mostly Sunny" : 30,
	"Mostly Sunny with Hazy" : 19,
	"Mostly Sunny with Light Rain" : 12,
	"Not Available" : 44,
	// "Partly Cloudy" : 29,
	"Partly Cloudy" : 30,
	"Partly Cloudy with Hazy" : 19,
	"Partly Cloudy with Light Rain" : 12,
	"Partly Cloudy with Mist and Fog" : 20,
	"Partly Cloudy with Scattered Snow" : 41,
	"Partly Cloudy/Windy" : 30,
	"Snow Shower" : 14,
	"Sunny" : 32,
	"Sunny with Drizzle" : 9,
	"Sunny with Hazy" : 19,
	"Sunny with Light Rain" : 12,
	"Sunny with Light Snow" : 42,
	"Sunny with Mist and Fog" : 20,
	"Sunny with Rain" : 12,
	"Windy with Snow Likely" : 43,
	"Windy with Snow Showers Likely" : 41
};
