goog.provide("DRE.UI");

goog.require("UI");
goog.require("dtv.Background");
goog.require("dtv.fs.Clock");
goog.require("dtv.fs.Fullscreen");

/**
 * Handles the screens, backgrounds and visibility of dom elements in the app
 * @param {Object} baseController Reference to the DRE controller instance
 * @constructor
 */
DRE.UI = function(baseController){
	this.baseController_ = baseController;
	this.isChrome_ = navigator.userAgent.indexOf('Chrome') !== -1;
	this.clock_ = null;
};

/**
 * @param {string} newScreen
 */
DRE.UI.prototype.changeScreen = function(newScreen){
	if(this.currentScreen_ && this.currentScreen_ !== newScreen){
		UI.hideEl(this.currentScreen_);
	}
	UI.showEl(newScreen);
	this.currentScreen_ = newScreen;
};

/**
 * @param {string} defaultBackground
 */
DRE.UI.prototype.changeBackground = function(defaultBackground, newBackgroundHD, newBackgroundNormal, newBackgroundConfig){
   //call the change background if needed
    var background = '';
    var new_mpeg = '';
    var new_png = '';
    if(newBackgroundHD != undefined && newBackgroundHD != '') {
        background = newBackgroundHD;
        new_mpeg = newBackgroundHD;
        new_png = newBackgroundNormal;
    } else {
        background = defaultBackground;
        new_mpeg = "assets/mpegs/"+ defaultBackground+"_HD.mpg";
        new_png = "assets/mpegs/" + defaultBackground+".png";
    }

    console.log("### [INFO][BACKGROUND] HD: " + new_mpeg);
    console.log("### [INFO][BACKGROUND] NORMAL: " + new_png);

		if(newBackgroundConfig != undefined && newBackgroundConfig != '') {
			dtv.Background.set( new_mpeg, new_png, newBackgroundConfig );
		} else {
			dtv.Background.set( new_mpeg, new_png, dtv.Background.PRESETS.DRECENTER );
		}

    if(background == dtv.fs.BLANK_ASSET){
      if(this.clock_){
        this.clock_.destroy();
      }
    }
    else{
      this.clock_ = new dtv.fs.Clock();
    }
};

/**
 * @param {string} background
 * @param {string} screenId
 * @param {string} containerId
 * @param {boolean} showPig
 */
DRE.UI.prototype.display = function(background, customBackgroundHD, customBackgroundNormal, screenId, containerId, backgroundConfig){
//RE.UI.prototype.display = function(background, screenId, containerId, customBackgroundHD, customBackgroundNormal){
  this.changeBackground(background, customBackgroundHD, customBackgroundNormal, backgroundConfig);
  this.changeScreen(screenId);
  UI.showEl(containerId);
};
