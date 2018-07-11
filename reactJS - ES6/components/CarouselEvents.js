'use strict';

import React from 'react';
import {bindActionCreators} from 'redux';
import {connect} from 'react-redux';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';
import _ from 'lodash';

import CarouselItem from './CarouselItem';
import CarouselItemCab from './CarouselItemCab';
import ActionLinks from '../shared_components/ActionLinks';

import * as ScreenDim from '../../../model/ScreenDimensions';

import {SoundTypes, SubNavigationSounds} from '../../../api/sounds';

import {withNavigation} from '../../../enhancers/Navigation';

import {withPosters, withEvents} from '../../../enhancers/DataRetriever';

import {
    CLICK,
    KEYBOARD,
    MIDDLE,
    NOOP,
    REC
} from '../../../constants/constants';

import {
    Context,
    Defaults,
    Orientation,
    ProgType
} from '../../../constants/UIConfig';

import {
    compose,
    getProgTypeFromTmsId,
    isEmptyObject,
    isEpisodic
} from '../../../constants/Utils';

import {BookingHelper} from '../../../constants/BookingUtils';

import {
    adjustVolume,
    enableCAM, disableCAM,
    cancelRecording,
    dispatchAction,
    getSoundAction,
    loadCommonInfoPage,
    requestCancelSeries,
    scheduleRecording
} from '../../../actions/actions';

import {carouselCenterVariableScroll} from '../../../model/CarouselCal';

const CAB_WIDTH = 1000;
const SINGLE_COLUMN_WIDTH = 102;
const ACTION_WIDTH = 174;

class CarouselEvents extends React.Component {

    static propTypes = {

        // From CarouselList component
        carousel: React.PropTypes.number.isRequired, // Current tab index
        currCategory: React.PropTypes.string.isRequired, // Current carousel name
        nextCategory: React.PropTypes.string.isRequired, // Next carousel name
        orientation: React.PropTypes.string.isRequired, // Orientation of posters (Landscape, Portrait or Mixed)
        index: React.PropTypes.number.isRequired, // Index of the carousel (0: top most)
        active: React.PropTypes.bool.isRequired, // True if an item in the carousel is selected/highlighted
        items: React.PropTypes.array.isRequired, // List of items
        actions: React.PropTypes.array.isRequired, // List of actions

        // From DataRetriever
        events: React.PropTypes.object.isRequired,
        posters: React.PropTypes.object.isRequired,

        // From withNavigation
        selected: React.PropTypes.object.isRequired,
        action: React.PropTypes.object.isRequired,
        sound: React.PropTypes.object.isRequired
    };

    constructor(props) {
        super(props);
        this.state = this.getDefaultState();
    }

    getDefaultState = () => {
        let numOfItems = this.props.items.length;
        let events = {};
        let posters = {};
        for (let i = 0; i < numOfItems; ++i) {
            let tmsId = this.props.items[i];
            events[tmsId] = Defaults.Event.Empty;
            switch (this.props.orientation) {
                case Orientation.Portrait:
                    posters[tmsId] = Defaults.Poster.Portrait;
                    break;
                case Orientation.Mixed:
                    for (let i = 0; i < numOfItems; i++) {
                        switch (getProgTypeFromTmsId(this.props.items[i])) {
                            case ProgType.Movie:
                                posters[tmsId] = Defaults.Poster.Portrait;
                                break;
                            case ProgType.Episode:
                            case ProgType.Show:
                            case ProgType.SportingEvent:
                            default:
                                posters[tmsId] = Defaults.Poster.Landscape;
                                break;
                        }
                    }
                    break;
                case Orientation.Landscape:
                default:
                    posters[tmsId] = Defaults.Poster.Landscape;
                    break;
            }
        }

        let widths = new Array(numOfItems);
        widths.push(2.36);
        
        switch(this.props.orientation) {
            case Orientation.Portrait:
                widths.fill(2);
                break;
            case Orientation.Mixed:
                for (let i = 0; i < numOfItems; i++) {
                    widths[i] = (getProgTypeFromTmsId(this.props.items[i]) === ProgType.Movie) ? 2 : 4;
                }
                break;
            case Orientation.Landscape:
            default:
                widths.fill(4);
                break;
        }

        return {
            events,
            posters,
            widths,
            currRow: this.props.selected.row,
            currCol: this.props.selected.cols[this.props.selected.row],
            scrollX: 0,
            position: 'right'
        };
    };

    shouldComponentUpdate(nextProps, nextState) {

        // Events available
        if (isEmptyObject(this.props.events) && !isEmptyObject(nextProps.events)) {
            nextState.events = nextProps.events;
        }

        // Posters available
        if (isEmptyObject(this.props.posters) && !isEmptyObject(nextProps.posters)) {
            for (let i = 0; i < this.props.items.length; ++i) {
                let tmsId = this.props.items[i];
                let ratio = '4x3';
                if (this.props.orientation === Orientation.Portrait ||
                        (this.props.orientation === Orientation.Mixed && getProgTypeFromTmsId(tmsId) === ProgType.Movie)) {
                    ratio = '2x3';
                }
                let poster = nextProps.posters[tmsId];
                if (poster) {
                    nextState.posters[tmsId] = poster[ratio];
                } else {
                    nextState.posters[tmsId] = (ratio === '4x3') ? Defaults.Poster.Landscape : Defaults.Poster.Portrait;
                }
            }
        }

        // Action available
        if (this.props.action.id !== nextProps.action.id) {
            let volume = this.props.menuView.settings.audio.selected;
            let action = nextProps.action;
            let currRow = this.props.selected.row;
            let currCol = this.props.selected.cols[currRow];
            let itemIndex = currCol - 1;
            switch (action.type) {
                case NOOP:
                    break;
                case KEYBOARD:
                    switch (action.event.direction) {
                        case 'i':
                        // case 'v':
                            if (!nextProps.contextualView.active) {
                                this.props.enableCAM(Context.Menu);
                            }
                            break;
                        default:
                            this.props.dispatchAction(action);
                            break;
                    }
                    break;
                case CLICK:
                    if (action.event.direction === MIDDLE) {
                        // Highlight in one of the carousel items
                        // Load Common Info Page
                        if (currCol > 0) {
                            let tmsId = this.props.items[itemIndex];
                            let event = this.state.events[tmsId];
                            if (event && event.tmsId) {
                                let request = {
                                    tmsId: event.tmsId,
                                    active: false,
                                    channel: {
                                        ccid: null,
                                        major: null
                                    }
                                };
                                this.props.loadCommonInfoPage(request);
                            }
                        }
                    } else {
                        this.props.dispatchAction(action);
                    }
                    break;
                case REC:
                    if (itemIndex < 0) {
                        break;
                    }
                    let tmsId = this.props.items[itemIndex];
                    let isScheduled = BookingHelper.isScheduledById(tmsId, this.props.todos.list);
                    let isRecurring = BookingHelper.isRecurringById(tmsId, this.props.todos.list);
                    // Series is already scheduled, display OSD
                    if (isScheduled && isRecurring) {
                        this.props.requestCancelSeries(tmsId);
                    }
                    // One-shot is scheduled, cancel it
                    else if (isScheduled && !isEpisodic(tmsId)) {
                        this.props.cancelRecording(tmsId, volume);
                    }
                    // Schedule
                    else {
                        let request = {
                            program: { tmsId },
                            channel: {
                                id: null,
                                major: null
                            },
                            active: false
                        };
                        this.props.scheduleRecording(request, volume);
                    }
                    break;
                default:
                    break;
            }
        }

        if (this.props.sound.id !== nextProps.sound.id) {
            let volume = this.props.menuView.settings.audio.selected;
            this.props.dispatchAction(adjustVolume(nextProps.sound, volume));
        }

        // Process side-by-side navigation and calculate how much to shift horizontally
        let currCol = this.state.currCol;
        let nextRow = nextProps.selected.row;
        let nextCol = nextProps.selected.cols[nextRow];
        if (currCol !== nextCol) {
            let numOfItems = this.props.items.length;
            let margin = Defaults.Navigation.Carousel.col.margin;
            let colWidth = Defaults.Navigation.Carousel.col.singleColWidth;
            let actionWidth = Defaults.Navigation.Carousel.action.width;
            let extraWidth = Defaults.Navigation.Carousel.extra.left;
            let scroll = (currCol > nextCol) ?
                carouselCenterVariableScroll(
                    numOfItems + 1, margin, 'X', currCol - 2, colWidth, extraWidth, actionWidth, this.state.widths) :
                carouselCenterVariableScroll(
                    numOfItems + 1, margin, 'X', currCol, colWidth, extraWidth, actionWidth, this.state.widths);

            nextState.currCol = nextCol;
            nextState.scrollX = scroll.dist;
            nextState.position = scroll.pos;
        }

        return true;
    }

    render() {
        let activeRow = this.state.currRow;
        let activeCol = this.state.currCol;
        let currCarouselLen = this.props.items.length;
        let actionLinks = this.props.actions[0];
        let isActiveCarousel = this.props.active;
        let isCabActive = this.props.contextualView.active && this.props.contextualView.context === Context.Menu;
        let cabPos = this.state.position;
        if (activeCol === 0 && activeRow === 0) {
            cabPos = 'right';
        }

        // Adjust horizontal movement if carousel item is expanded
        let offset = this.state.scrollX;
        let cabAdjust = 0;
        let colNum = this.state.widths[activeCol - 1];
        let activeColWidth = colNum * SINGLE_COLUMN_WIDTH;
        let posterCenter = ScreenDim.getScreenCenterXPerDom(activeColWidth);
        let cabCenter = ScreenDim.getScreenCenterXPerDom(activeColWidth + CAB_WIDTH);
        let colCount = activeCol;

        let posterPos = 10 * colCount;
        _.each(this.props.items, (item, index) => {
            if (cabPos === 'left' && index >= activeCol) {
                posterPos += this.state.widths[index] * SINGLE_COLUMN_WIDTH;
            }
            if (cabPos === 'right' && index < activeCol) {
                posterPos += this.state.widths[index] * SINGLE_COLUMN_WIDTH;
            }
        });

        let cabCenterInner = ScreenDim.getScreenCenterXPerDom(activeColWidth + CAB_WIDTH, ACTION_WIDTH);

        if (isCabActive && activeCol > 0 && activeCol < currCarouselLen) {
            if (cabPos === 'middle') {
                cabAdjust = posterCenter - cabCenter
            } else if (cabPos === 'right') {
                if (posterPos > cabCenterInner) {
                    cabAdjust = posterPos - cabCenterInner;
                }
            }
        }

        let calStyle = { "transform": "translateX(" + (offset - cabAdjust) + "px)" };
        
        let rowIndex = this.props.index;
        let selectedRowIndex = this.props.menuView.carouselIndex;

        let greyStyle =  { "opacity": "1.0" };

        if ( (rowIndex < selectedRowIndex) || (rowIndex !== 0 && (selectedRowIndex === -1 || selectedRowIndex === 0) )) {
            greyStyle = {"opacity": "0"};
        }

        let carouselTitle = this.props.currCategory;
        let labelClass = "carousel-title";
        if (isCabActive) {
            labelClass += " selected";
        }

        let carouselType = 'Program';

        let self = this;     
        return (
            <div className="carousel-wrap">
                <div className="carousel" style={greyStyle}>
                    <label className={labelClass}>{carouselTitle}</label>
                    <ul style={calStyle}>
                        <ActionLinks actionLinks={actionLinks} active={isActiveCarousel && activeCol === 0} />
                        {
                            _.map(this.props.items, (tmsId, index) => {
                                let active = (isActiveCarousel && ((index + 1) === activeCol));
                                let expanded = isCabActive;
                                let isCabOn = (active & expanded);

                                let event = self.state.events[tmsId];
                                if (!event) {
                                    event = Defaults.Event.NotAvailable;
                                }
                                let poster = self.state.posters[tmsId];
                                let folder = [event];
                                let data = { event, folder, poster };

                                // Determine the width of the poster
                                let width = 4;
                                if (self.props.orientation === Orientation.Portrait ||
                                        (self.props.orientation === Orientation.Mixed &&
                                        getProgTypeFromTmsId(tmsId) === ProgType.Movie)) {
                                    width = 2;
                                }

                                let carouselItemCab = null;
                                if (isCabOn) {
                                    let Initial = { row: 0, col: 0 };
                                    let Map = new Array(5).fill(1); // For now, assume 5 number of CTAs
                                    let StopPropagation = true;
                                    carouselItemCab = <CarouselItemCab Initial={Initial} Map={Map}
                                                                       StopPropagation={StopPropagation} Sounds={SubNavigationSounds}
                                                                       key={index+1} type={carouselType} data={data}
                                                                       pos={cabPos} width={width*SINGLE_COLUMN_WIDTH}
                                                                       Cabindex={index} display={isCabOn} showDots={false} />;
                                }

                                return (
                                    <li className="list-items-wrap">
                                        <ReactCSSTransitionGroup transitionAppear={true} transitionAppearTimeout={200}
                                                                 transitionEnterTimeout={200} transitionLeaveTimeout={200}
                                                                 transitionName="cab-overlay">
                                            <CarouselItem key={index} type={carouselType} data={data} index={index}
                                                          active={active} width={width} isCabActive={isCabActive} />
                                            {carouselItemCab}
                                        </ReactCSSTransitionGroup>
                                    </li>
                                );
                            })}
                        <ActionLinks actionLinks={actionLinks} active={isActiveCarousel && activeCol === currCarouselLen + 1} />
                    </ul>
                </div>
            </div>
        )
    }
}

const mapStateToProps = (state) => {
    return {
        contextualView: {
            active: state.events.contextualView.active,
            context: state.events.contextualView.context
        },
        menuView: {
            tabIndex: state.events.menuView.tabIndex,
            carouselIndex: state.events.menuView.carouselIndex,
            numOfCarousels: state.events.menuView.numOfCarousels,
            settings: {
                audio: {
                    selected: state.events.menuView.settings.audio.selected
                }
            }
        },
        todos: {
            list: state.todos.list
        }
    };
};

const mapDispatchToProps = dispatch => {
    return {
        enableCAM: bindActionCreators(enableCAM, dispatch),
        disableCAM: bindActionCreators(disableCAM, dispatch),
        cancelRecording: bindActionCreators(cancelRecording, dispatch),
        dispatchAction: bindActionCreators(dispatchAction, dispatch),
        getSoundAction: bindActionCreators(getSoundAction, dispatch),
        loadCommonInfoPage: bindActionCreators(loadCommonInfoPage, dispatch),
        requestCancelSeries: bindActionCreators(requestCancelSeries, dispatch),
        scheduleRecording: bindActionCreators(scheduleRecording, dispatch)
    };
};

const attributes = {
    event: ['tmsId', 'title', 'episodeTitle', 'description', 'seasonNumber', 'episodeNumber', 'progType', 'rating', 'ppv', 'firstRun', 'tomatoScore', 'audienceScore', 'runLength', 'releaseDate'],
    poster: ['height', 'width', 'url'],
    ratios: ['4x3', '2x3'],
    onActive: true
};

const enhance = compose(
    withNavigation(attributes.onActive),
    withPosters(attributes.poster, attributes.ratios),
    withEvents(attributes.event),
    connect(mapStateToProps, mapDispatchToProps)
);

export default enhance(CarouselEvents);
