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

import {withNavigation} from '../../../enhancers/Navigation';

import {
    withChannels,
    withSchedules,
    withEvents,
    withPosters
} from '../../../enhancers/DataRetriever';

import {SoundTypes, SubNavigationSounds} from '../../../api/sounds';

import {
    CLICK,
    KEYBOARD,
    MIDDLE,
    NOOP,
    REC
} from '../../../constants/constants';

import {Context, Defaults} from '../../../constants/UIConfig';

import {
    compose,
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

class CarouselChannels extends React.Component {

    static propTypes = {

        // from CarouselList component
        carousel: React.PropTypes.number.isRequired, // current tab index
        currCategory: React.PropTypes.string.isRequired, // current carousel name
        nextCategory: React.PropTypes.string.isRequired, // next carousel name
        orientation: React.PropTypes.string.isRequired, // orientation of posters (Landscape, Portrait or Mixed)
        index: React.PropTypes.number.isRequired, // index of the carousel (0: top most)
        active: React.PropTypes.bool.isRequired, // true if an item in the carousel is selected/highlighted
        items: React.PropTypes.array.isRequired, // list of items
        actions: React.PropTypes.array.isRequired, // list of actions

        // from DataRetriever
        channels: React.PropTypes.object.isRequired,
        schedules: React.PropTypes.object.isRequired,
        events: React.PropTypes.object.isRequired,
        posters: React.PropTypes.object.isRequired,

        // from withNavigation
        selected: React.PropTypes.object.isRequired,
        action: React.PropTypes.object.isRequired,
        sound: React.PropTypes.object.isRequired
    };

    constructor(props) {
        super(props);

        let schedules = {}, channels = {}, events = {}, posters = {};
        let numOfItems = this.props.items.length;
        for (let i = 0; i < numOfItems; ++i) {
            let channelId = this.props.items[i];
            schedules[channelId] = Defaults.Schedule.Empty;
            channels[channelId] = Defaults.Channel.Empty;
        }
        events['default'] = Defaults.Event.Empty;
        posters['default'] = {
            '4x3': Defaults.Poster.Landscape,
            '2x3': Defaults.Poster.Portrait
        };

        let widths = new Array(numOfItems).fill(4);
        widths.push(1.7);
        
        this.state = {
            schedules,
            channels,
            events,
            posters,
            widths,
            currRow: this.props.selected.row,
            currCol: this.props.selected.cols[this.props.selected.row],
            scrollX: 0,
            position: 'right'
        };
    }

    shouldComponentUpdate(nextProps, nextState) {

        // channels available
        if (isEmptyObject(this.props.channels) && !isEmptyObject(nextProps.channels)) {
            nextState.channels = nextProps.channels;
        }

        // schedules available
        if (isEmptyObject(this.props.schedules) && !isEmptyObject(nextProps.schedules)) {
            for (let i = 0; i < this.props.items.length; ++i) {
                let channelId = this.props.items[i];
                let schedule = nextProps.schedules[channelId];
                if (schedule) {
                    let startTimeMs = new Date(schedule.startTime).getTime();
                    nextState.schedules[channelId] = {
                        tmsId: schedule.tmsId,
                        startTime: startTimeMs / 1000,
                        videoPercentage: Math.floor((new Date().getTime() - startTimeMs) / (schedule.duration * 600)),
                        duration: schedule.duration * 60
                    };
                } else {
                    nextState.schedules[channelId] = {
                        tmsId: 'default',
                        startTime: 0,
                        videoPercentage: 0,
                        duration: 0
                    };
                }
            }
        }

        // events available
        if (isEmptyObject(this.props.events) && !isEmptyObject(nextProps.events)) {
            nextState.events = nextProps.events;
        }

        // posters available
        if (isEmptyObject(this.props.posters) && !isEmptyObject(nextProps.posters)) {
            nextState.posters = nextProps.posters;
        }

        // process actions
        if (this.props.action.id !== nextProps.action.id) {
            let action = nextProps.action;
            let currRow = this.props.selected.row;
            let currCol = this.props.selected.cols[currRow];
            let itemIndex = currCol - 1;
            let volume = this.props.menuView.settings.audio.volume;
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
                        // highlight in one of the carousel items
                        // load Common Info Page
                        if (currCol > 0) {
                            let channelId = this.props.items[itemIndex];
                            let eventId = this.state.schedules[channelId].tmsId;
                            let event = this.state.events[eventId];
                            if (event && event.tmsId) {
                                let request = {
                                    tmsId: event.tmsId,
                                    active: false,
                                    channel: {
                                        ccid: null,
                                        major: null
                                    }
                                };
                                let channel = this.state.channels[channelId];
                                request.active = true;
                                request.channel = {
                                    ccid: channel.ccid,
                                    major: channel.majorChannelNumber
                                };
                                let schedule = this.state.schedules[channelId];
                                request.schedule = {
                                    startTime: schedule.startTime,
                                    duration: schedule.duration
                                };
                                this.props.loadCommonInfoPage(request);
                            }
                        }
                    } else {
                        this.props.dispatchAction(action);
                    }
                    break;
                case REC:
                    if (currCol < 1) {
                        break;
                    }
                    let channelId = this.props.items[itemIndex];
                    let eventId = this.state.schedules[channelId].tmsId;
                    let event = this.state.events[eventId];
                    let tmsId = event.tmsId;
                    let isScheduled = BookingHelper.isScheduledById(tmsId, this.props.todos.list);
                    let isRecurring = BookingHelper.isRecurringById(tmsId, this.props.todos.list);
                    // series is already scheduled, display OSD
                    if (isScheduled && isRecurring) {
                        this.props.requestCancelSeries(tmsId);
                    }
                    // one-shot is scheduled, cancel it
                    else if (isScheduled && !isEpisodic(tmsId)) {
                        this.props.cancelRecording(tmsId, volume);
                    }
                    // schedule
                    else {
                        let request = {
                            program: {
                                tmsId: tmsId
                            },
                            channel: {
                                id: null,
                                major: null
                            },
                            active: false
                        };
                        request.channel = {
                            ccid: channelId,
                            major: this.state.channels[channelId].majorChannelNumber
                        };
                        request.schedule = {
                            startTime: this.state.schedules[channelId].startTime,
                            duration: this.state.schedules[channelId].duration
                        };
                        request.active = true;
                        this.props.scheduleRecording(request, volume);
                    }
                    break;
                default:
                    //this.props.dispatchAction(action);
                    break;
            }
        }

        if (this.props.sound.id !== nextProps.sound.id) {
            let volume = this.props.menuView.settings.audio.selected;
            this.props.dispatchAction(adjustVolume(nextProps.sound, volume));
        }

        // process side-by-side navigation and calculate how much to shift horizontally
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
        let actionLinks = this.props.actions[0]; // only use 1st action
        let isActiveCarousel = this.props.active;
        let isCabActive = this.props.contextualView.active && this.props.contextualView.context === Context.Menu;
        let cabPos = this.state.position;
        if (activeCol === 0 && activeRow === 0) {
            cabPos = 'right';
        }

        // adjust horizontal movement if carousel item is expanded
        let offset = this.state.scrollX;
        let cabAdjust = 0;
        //let colNum = 4;
        let colNum = this.state.widths[activeCol - 1];
        let activeColWidth = colNum * SINGLE_COLUMN_WIDTH;
        let posterCenter = ScreenDim.getScreenCenterXPerDom(activeColWidth);
        let cabCenter = ScreenDim.getScreenCenterXPerDom(activeColWidth + CAB_WIDTH);
        let colCount = activeCol;
        let posterPos = 10 * colCount;
        _.each(this.props.items, (item, index) => {
            if (cabPos === 'left' && index >= activeCol) {
                //posterPos += 4 * SINGLE_COLUMN_WIDTH;
                posterPos += this.state.widths[index] * SINGLE_COLUMN_WIDTH;
            }
            if (cabPos === 'right' && index < activeCol) {
                //posterPos += 4 * SINGLE_COLUMN_WIDTH;
                posterPos += this.state.widths[index] * SINGLE_COLUMN_WIDTH;
            }
        });

        let cabCenterInner = ScreenDim.getScreenCenterXPerDom(activeColWidth + CAB_WIDTH, ACTION_WIDTH);

        if (isCabActive && activeCol > 0 && activeCol < currCarouselLen) {
            if (cabPos === 'middle') {
                cabAdjust = posterCenter - cabCenter;
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

        let carouselType = 'Channel';

        let self = this;        
        return (
            <div className="carousel-wrap">
                <div className="carousel" style={greyStyle}>
                    <label className={labelClass}>{carouselTitle}</label>
                    <ul style={calStyle}>
                        <ActionLinks actionLinks={actionLinks} active={isActiveCarousel && activeCol === 0} />
                        {
                            _.map(this.props.items, (channelId, index) => {
                                let active = (isActiveCarousel && ((index + 1) === activeCol));
                                let expanded = isCabActive;
                                let isCabOn = (active & expanded);

                                let channel = self.state.channels[channelId];
                                let schedule = self.state.schedules[channelId];
                                let eventId = schedule.tmsId;
                                let event = self.state.events[eventId];
                                if (!event) {
                                    event = Defaults.Event.Empty;
                                }
                                let aspectRatio = '4x3';
                                let poster = self.state.posters[eventId];
                                if (!poster) {
                                    poster = Defaults.Poster.Landscape;
                                } else {
                                    poster = poster[aspectRatio];
                                }
                                let folder = [event];
                                let data = { channel, schedule, event, folder, poster };

                                // determine the width of the poster
                                let width = 4;

                                let carouselItemCab = null;
                                if (isCabOn) {
                                    let Initial = { row: 0, col: 0 };
                                    let Map = new Array(5).fill(1); // for now, assume 5 number of CTAs
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
        );
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
    onActive: true,
    channel: ['ccid', 'logo', 'shortName', 'majorChannelNumber'],
    schedule: ['tmsId', 'startTime', 'duration'],
    event: ['tmsId', 'title', 'episodeTitle', 'description', 'seasonNumber', 'episodeNumber', 'progType', 'rating', 'ppv', 'firstRun', 'tomatoScore', 'audienceScore', 'runLength', 'releaseDate'],
    ratios: ['4x3', '2x3'],
    poster: ['height', 'width', 'url']
};

const enhance = compose(
    withNavigation(attributes.onActive),
    withChannels(attributes.channel),
    withSchedules(attributes.schedule),
    withPosters(attributes.poster, attributes.ratios),
    withEvents(attributes.event),
    connect(mapStateToProps, mapDispatchToProps)
);

export default enhance(CarouselChannels);