goog.provide('DOCK.Controller');

goog.require('Environment');
goog.require('dtv.mvc.Controller');
goog.require('dtv.ui');
goog.require('dtv.ajax');
goog.require('dtv.cookie');
goog.require('dtv.io.Remote');
goog.require('dtv.analytics.Omniture');
goog.require('dtv.STBInfo');

goog.require('DOCK.views.BaseView');
goog.require('DOCK.Require');

/**
 * @constructor
 * @extends dtv.mvc.Controller
 */
DOCK.Controller = function() {
    goog.base(this);
    this.omniture_ = null;

    this.splash_ = false;
    this.noKeypress_ = false;
    this.appLoaded_ = false;

    this.urlParams = this.getURLParams();
    this.activeAppId = this.getAppId('appid');

    this.CE = !!(window.location.hostname == 'int-iw.dtvce.com' || window.location.hostname == 'localhost');

    window.setTimeout(goog.bind(this.init, this), 500);
}
goog.inherits(DOCK.Controller, dtv.mvc.Controller);

DOCK.Controller.prototype.init = function() {
    this.omniture_ = new dtv.analytics.Omniture('Homepage');
    document.getElementById('app').classList.remove('hidden');

    if(this.firstLoad_() && !this.activeAppId){
        this.loadSplash();
    }else{
        this.loadDock();
        document.getElementById('dock').classList.remove('hidden');
    }

    this.setTimer(); 
}

DOCK.Controller.prototype.appAutoClose = function(){
    if(!this.appLoaded_){
        window.console.log('5 minutes of inactivity reached, Dock closing');
        if(!dtv.ui.isChrome()) navigator['Exit']();
    }
};

DOCK.Controller.prototype.setTimer = function(){
    if(this.appTimer_)
        this.clearTimer();

    this.appTimer_ = window.setTimeout(goog.bind(this.appAutoClose,this),300000);
};

DOCK.Controller.prototype.clearTimer = function(){
    window.clearTimeout(this.appTimer_);
};

DOCK.Controller.prototype.appLoaded = function(){
    this.appLoaded_ = true;
};

DOCK.Controller.prototype.getLoadStatus = function(){
    return this.appLoaded_;
};
goog.exportSymbol('loadStatus', DOCK.Controller.prototype.getLoadStatus);

DOCK.Controller.prototype.keyHandlerInternal_ = function(key){
    if(this.noKeypress_) return false;

    this.setTimer(); 

    switch(key.keyCode){
        case dtv.io.Remote.LEFT:
        case dtv.io.Remote.BACK:
            if(!dtv.ui.isChrome()) navigator['Exit']();
            break;
        default:
            if(~dtv.io.Remote.NUMPAD.indexOf(key.keyCode) || ~dtv.io.Remote.TRICKPLAY.indexOf(key.keyCode)){
                window.console.log('***** Current keypress ' + key.keyCode + ' requires app to exit. Goodbye. *****');
                if(!dtv.ui.isChrome()) window.setTimeout(function(){navigator['Exit']()},500);
            }
            break;
    }
    return false;
};

DOCK.Controller.prototype.removeSplash = function(){
    var img = document.getElementById("ftux");
    this.showSnipe = false;
    
    if(img)
        img.parentNode.removeChild(img);

    this.keyPressOn = false;
    window.setTimeout(goog.bind(this.reactivateKeypress_, this),500);

    this.removeFromMap_('app');

    this.loadDock();
    this.setTimer(); 
    document.getElementById('dock').classList.remove('hidden');
}

DOCK.Controller.prototype.reactivateKeypress_ = function(){
    this.noKeypress_ = false;
};

DOCK.Controller.prototype.firstLoad_ = function() {
    var cookie = dtv.cookie.get('dock');
    
    if(cookie.length==0){
        dtv.cookie.set('dock','1');
        return true;
    }

    return false;
}

DOCK.Controller.prototype.loadSplash = function(){
    this.noKeypress_ = true;

    this.addToMap_('app', new DOCK.views.Splash());
    this.focused_ = this.getFromMap_('app');

    window.setTimeout(goog.bind(this.reactivateKeypress_, this),2000);
}

DOCK.Controller.prototype.loadDock = function(){
    if(this.focused_ instanceof DOCK.views.Dock)
        return false;

    this.noKeypress_ = true;

    this.addToMap_('app', new DOCK.views.Dock(this));
    this.focused_ = this.getFromMap_('app');

    window.setTimeout(goog.bind(this.reactivateKeypress_, this),1000);
}

DOCK.Controller.prototype.getAppId = function(param){
    return this.urlParams[param] || 0;
};

DOCK.Controller.prototype.getURLParams = function(){
    var url = window.location;
    var p = {}, key,
        pairs = url.search.substr(1).split("&"),
        max = pairs.length;

    if (url.search.length > 1) {
        while(max--) {
            key = pairs[max].split("=");
            p[unescape(key[0])] = key.length > 1 ? unescape(key[1]) : "";
        }
    }
    return p;
};

/**
 * @constructor
 */
DOCK.views.Splash = function() {
    this.parentElementId_ = 'app';
    this.elementId_ = 'splash';

    goog.base(this);
}
goog.inherits(DOCK.views.Splash, DOCK.views.BaseView);

DOCK.views.Splash.prototype.disposeInternal = function() {
    goog.base(this, 'disposeInternal');
}

DOCK.views.Splash.prototype.decorateInternal = function(element) {
    goog.base(this, 'decorateInternal', element);
    if(!this.focused_){
        this.splash_ = document.createElement('img');
        this.splash_.id = 'ftux';
        this.splash_.src = 'images/tvapp_welcomescreen_03.jpg';
        this.getElement().appendChild(this.splash_);
    }
}

DOCK.views.Splash.prototype.addComponents = function() {
    window.setTimeout(goog.bind(this.publishSelection_, this),30000);
}

DOCK.views.Splash.prototype.reload = function(newData) {
    return false;
}

DOCK.views.Splash.prototype.keyHandlerInternal_ = function(key) {
    if((key.keyCode==dtv.io.Remote.SELECT || key.keyCode==dtv.io.Remote.RIGHT)){
        this.publishSelection_();
    }else{
        return false;
    }
}

DOCK.views.Splash.prototype.publishSelection_ = function(key) {
    dock.removeSplash();
}

/**
 * @constructor
 */
DOCK.views.Dock = function(controller) {
    this.controller_ = controller;
    this.parentElementId_ = 'app';
    this.elementId_ = 'dock';
    this.widgetData = null;
    this.stbInfo = new dtv.STBInfo();

    goog.base(this);
}
goog.inherits(DOCK.views.Dock, DOCK.views.BaseView);

DOCK.views.Dock.prototype.disposeInternal = function() {
    goog.base(this, 'disposeInternal');
}

DOCK.views.Dock.prototype.decorateInternal = function(element) {
    goog.base(this, 'decorateInternal', element);
    if(!this.focused_){
        this.appListEle_ = document.createElement('div');
        this.appListEle_.id = 'applist';
        this.getElement().appendChild(this.appListEle_);
    }
}

DOCK.views.Dock.prototype.addComponents = function() {
    if(!this.focused_){
        this.getData_();
        this.prepIframe();
    }
}

DOCK.views.Dock.prototype.reload = function(newData) {
    return false;
}

DOCK.views.Dock.prototype.prepIframe = function() {
    var iframe = document.getElementById('app-embed');

    iframe.onload = goog.bind(this.onAppLoaded,this);
}
goog.exportSymbol('prepIframe', DOCK.views.Dock.prototype.prepIframe);

DOCK.views.Dock.prototype.keyHandlerInternal_ = function(key) {
    if(key.keyCode == dtv.io.Remote.UP || key.keyCode == dtv.io.Remote.DOWN || key.keyCode == dtv.io.Remote.PAGEUP || key.keyCode == dtv.io.Remote.PAGEDOWN)
        return true;

    return false;
}

DOCK.views.Dock.prototype.publishSelection_ = function(item) {
    var appId = item.domId_.substr(6);
    var app = this.getWidgetData(appId);

    window.console.log('Opening ' + app['name']);
    document.getElementById(item.domId_).classList.add('loading');
    
    var iframe = document.getElementById('app-embed');    
    var iframeLoadTimeAllowed = 10000;    
    var timeout = setTimeout(function() {
        console.log("iFrame's loading time exceeded " + (iframeLoadTimeAllowed / 1000) + " seconds!");
        document.querySelector('.loading').classList.remove('loading');
        clearTimeout(timeout)}, iframeLoadTimeAllowed);
    iframe.addEventListener('load', function() {
        clearTimeout(timeout);
    });

    if(app['preflight']){
        this.loadPreflight(app);
    }else{
        //remove any parameters from current URL before appending to new URL
        this.loadEmbeddedApp(app['appURL'] + 'returnURL=' + encodeURIComponent(window.location.protocol + '//' + window.location.host + window.location.pathname + '?appid=' + appId));  
    }
}

DOCK.views.Dock.prototype.loadEmbeddedApp = function(url) {
    var iframe = document.getElementById('app-embed');

    window.console.log('Loading URL: ' + url);

    iframe.src = url;   
}
goog.exportSymbol('loadApp', DOCK.views.Dock.prototype.loadEmbeddedApp);

DOCK.views.Dock.prototype.loadPreflight = function(app) {
    var s = document.createElement('script');
    s.src = app['preflight'];
    document.body.appendChild(s);
}

DOCK.views.Dock.prototype.getWidgetData = function(appId) {
    var appList = this.widgetData;
    var appData, url;

    for(var i=0; i<appList.length; i++){
        if(appList[i]['id']==appId){
            appData = appList[i];

            url = appList[i]['appURL'];

            if(url.substr(0,4)!='http')
                url = '../' + url;

            appData['appURL'] = url + (~url.indexOf('?') ? '&' : '?');

            break;
        }
    }

    return appData;
}

DOCK.views.Dock.prototype.onAppLoadedError = function() {
    var loadingApp = document.querySelector('.loading');
    var iframe = document.getElementById('app-embed');
    var newIframe = document.createElement('iframe');

    window.console.log('Could not open app, unloading iframe.');

    //remove added methods to avoid infinite loops    
    iframe.onload = null;

    this.appLoaded_ = false;

    if(loadingApp)
       window.setTimeout(function(){document.querySelector('.loading').classList.remove('loading')},2000);

    window['customError'] = null;

    //recreate iframe and reset custom methods
    iframe.parentNode.removeChild(iframe);
    newIframe.id = 'app-embed';
    document.body.appendChild(newIframe);

    //function may lose scope if called from a preflight script
    //check if prepIframe method exists before firing
    if (this.prepIframe) {
        this.prepIframe();
    } else {
        goog.bind(dock.prepIframe, dock);
    }
}
goog.exportSymbol('loadFail', DOCK.views.Dock.prototype.onAppLoadedError);

DOCK.views.Dock.prototype.onAppLoaded = function() {
  var iframe = document.getElementById("app-embed");
  var iFrameTitle = iframe.contentDocument.title;
  var iFrameBody = iframe.contentDocument.body.firstElementChild.innerText;
    
  if (iFrameTitle.indexOf("HTTP Status 404") >= 0 || iFrameTitle.indexOf("HTTP Status 500") >= 0 || iFrameTitle.indexOf("HTTP Status 503") >= 0 || iFrameBody.indexOf("HTTP Status 404") >= 0 || iFrameBody.indexOf("HTTP Status 500") >= 0 || iFrameBody.indexOf("HTTP Status 503") >= 0) {
      this.onAppLoadedError();
  } else {
      this.unloadDock();
      iframe.classList.remove("hidden");
      iframe.contentWindow.focus();
  }
}

DOCK.views.Dock.prototype.unloadDock = function() {
    var iframe = document.getElementById('app-embed');
    
    window.console.log('App loaded successfully!');
    this.controller_.clearTimer();
    this.controller_.appLoaded();

    document.getElementById('app').classList.add('hidden');
    iframe.classList.remove('hidden');
    iframe.contentWindow.focus();
}

DOCK.views.Dock.prototype.createAppList_ = function() {
    var listConfig = {
        domId : this.appListEle_.id,
        action : goog.bind(this.publishSelection_, this),
        defaults : {
            active : true,
            theme : {
                defaultClass : "dtv-list",
                listItem : {
                    activeClass : "active",
                    selectedClass : "selected"
                }
            },
            viewportSize : 6,
            nodeSize : 136
        }
    };
    listConfig.items = this.createDockIcons_();
    
    if(!this.apps_){
        this.apps_ = dtv.list.factory.createList(listConfig,'scrollable');
        document.getElementById(this.appListEle_.id + '-arrow-prev').classList.add('hidden'); 
        
        if(listConfig.items.length<7)
            document.getElementById(this.appListEle_.id + '-arrow-next').classList.add('hidden'); 

        if(dock.activeAppId){
            var targetIcon = this.apps_.idToNode('dtvapp'+dock.activeAppId);
            this.apps_.setActiveNode(targetIcon);
            if(this.apps_.vPortTop_>0)
                document.getElementById(this.appListEle_.id + '-arrow-prev').classList.remove('hidden');
            if(targetIcon==this.apps_.listNavBottom_){
                document.getElementById(this.appListEle_.id + '-arrow-next').classList.add('hidden');
            }
        }

        this.focused_ = this.apps_;
    }else{
        this.apps_.rebuild(listConfig, true);
    }
}

DOCK.views.Dock.prototype.createDockIcons_ = function() {
    var data = this.widgetData;
    var now = +new Date();
    var items = [];
    var appsList = [];
    var icon, required;

    var flag3rdPartySTB = Environment.is3rdParty();
    for(var i = 0; i<data.length; i++){
        var support3rdPartySTB = data[i]['support3rdPartySTB'] !== 0;
        if (!support3rdPartySTB) {
            if (flag3rdPartySTB) {
                window.console.log('~' + data[i]['name'] + ' does not support 3rd party STB.');
                continue;
            }
        }
        
        if(!data[i]['enabled'])
            continue;

        if(!dock.CE && ((data[i]['startDate'] && data[i]['startDate'] > now) || (data[i]['endDate'] && data[i]['endDate'] < now)))
            continue;

        if(!dtv.ui.isChrome() && data[i]['require']){
            window.console.log('~' + data[i]['name'] + ' requires Dock prerequisites. Testing stb capabilities...');
            required = new DOCK.Require(data[i],this.stbInfo.logInfo(true));

            if(!required.test()){
                window.console.log('~' + data[i]['name'] + ' did not meet Dock prerequisites.');
                continue;
            }else{
                window.console.log('~Prerequisites met. Displaying ' + data[i]['name'] + '.');
            }
        }

        icon = document.createElement('img');
        icon.src = 'images/' + data[i]['icon'];
        icon.alt = data[i]['name'];
        icon.height = data[i]['iconHeight'];
        icon.width = data[i]['iconWidth'];

        appsList.push(data[i]['name']);

        items.push(dtv.list.factory.createListItem({id : 'dtvapp' + data[i]['id'], value : icon, css : {customClass : 'dockitem'}}));
    }

    this.controller_.omniture_.report(appsList.join('|'));

    return items;
}

DOCK.views.Dock.prototype.getData_ = function() {
    dtv.ajax({
        url : 'widget_data.js?ver=' + (+new Date()),
        ready : goog.bind(this.setData_, this),
        dead : goog.bind(this.noData_, this)
    });
}

DOCK.views.Dock.prototype.noData_ = function() {
    this.widgetData = [];
    this.createAppList_();
}

DOCK.views.Dock.prototype.setData_ = function(cb) {
    var items = cb.feed["tvApps"];
    var listData = [];

    for(var i=0; i<items.length; i++){
        listData.push(items[i]);
    }

    this.widgetData = listData;

    this.createAppList_();
}

DOCK.views.Dock.prototype.afterFocusedKeyHandler_ = function(key) {
    var top = this.focused_ ? this.focused_.vPortTop_ : -1;

    this.controller_.setTimer(); 

    if(!~top) return false;
    
    if(key.keyCode == dtv.io.Remote.UP || key.keyCode == dtv.io.Remote.DOWN || key.keyCode == dtv.io.Remote.PAGEUP || key.keyCode == dtv.io.Remote.PAGEDOWN){
        if(top == 0){
            document.getElementById(this.appListEle_.id + '-arrow-prev').classList.add('hidden');
        }else{
            document.getElementById(this.appListEle_.id + '-arrow-prev').classList.remove('hidden');
        }
    }

    if(top == this.focused_.totalNodeCount_-this.focused_.vPortSize_){
        document.getElementById(this.appListEle_.id + '-arrow-next').classList.add('no-arrow');
    }else{
        document.getElementById(this.appListEle_.id + '-arrow-next').classList.remove('no-arrow');
    }
}