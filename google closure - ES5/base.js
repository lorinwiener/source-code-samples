goog.provide('DOCK.views.BaseView');
goog.provide('DOCK.views.BaseViewManager');

goog.require('dtv.mvc.View');
goog.require('dtv.list.factory');
goog.require('dtv.io.Remote');

/**
 * @constructor
 * @extends {dtv.mvc.View}
 *
 * @param	{!goog.pubsub.PubSub}		channel
 * @param	{!dtv.mvc.DataProvider}         dataProvider
 * @param	{!goog.analytics.Reporter}	analyticsReporter
 * @param	{!boolean=}	                doNotRender
 */
DOCK.views.BaseView = function(channel, dataProvider, analyticsReporter, controller, doNotRender) {
    /**
     * @protected
     * @description To be provided by implementing view
     * @type {!String}
     */
    this.parentElementId_;

    /**
     * @protected
     * @description To be provided by implementing view
     * @type {!String}
     */
    this.elementId_;

    goog.base(this, channel, dataProvider, analyticsReporter, controller);

    if(!doNotRender) this.render(document.getElementById(this.parentElementId_));
}
goog.inherits(DOCK.views.BaseView, dtv.mvc.View);

DOCK.views.BaseView.prototype.createDom = function() {
    this.decorateInternal(document.createElement('div'));
}

DOCK.views.BaseView.prototype.decorateInternal = function(element) {
    goog.base(this, 'decorateInternal', element);
    this.setId(this.elementId_);
    this.getElement().id = this.getId();
}

DOCK.views.BaseView.prototype.enterDocument = function() {
    goog.base(this, 'enterDocument');
    document.getElementById(this.parentElementId_).classList.remove('hidden');
    this.addComponents();
}

/**
 * @protected
 * @description Must be provided by implementing view.
 */
DOCK.views.BaseView.prototype.addComponents = goog.abstractFunction;


DOCK.views.BaseView.prototype.exitDocument = function() {
    goog.base(this, 'exitDocument');
    document.getElementById(this.parentElementId_).classList.add('hidden');
}
