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
import {withCelebs} from '../../../enhancers/DataRetriever';

import {SoundTypes, SubNavigationSounds} from '../../../api/sounds';

import {
    CLICK,
    KEYBOARD,
    MIDDLE,
    NOOP,
    REC
} from '../../../constants/constants';

import {
    Context,
    Defaults
} from '../../../constants/UIConfig';

import {
    compose,
    hasErrorObject,
    isEmptyObject
} from '../../../constants/Utils';

import {
    adjustVolume,
    enableCAM,
    dispatchAction,
    getSoundAction,
    loadCommonInfoPage,
    requestCancelSeries
} from '../../../actions/actions';

import {carouselCenterVariableScroll} from '../../../model/CarouselCal';

const CAB_WIDTH = 1000;
const SINGLE_COLUMN_WIDTH = 102;
const ACTION_WIDTH = 174;

class CarouselCelebs extends React.Component {

    static propTypes = {

        // From CarouselList component
        carousel: React.PropTypes.number.isRequired, // current tab index
        currCategory: React.PropTypes.string.isRequired, // current carousel name
        nextCategory: React.PropTypes.string.isRequired, // next carousel name
        orientation: React.PropTypes.string.isRequired, // orientation of posters (Landscape, Portrait or Mixed)
        index: React.PropTypes.number.isRequired, // index of the carousel (0: top most)
        active: React.PropTypes.bool.isRequired, // true if an item in the carousel is selected/highlighted
        items: React.PropTypes.array.isRequired, // list of items
        actions: React.PropTypes.array.isRequired, // list of actions

        // From DataRetriever
        celebs: React.PropTypes.object.isRequired,

        // From withNavigation
        selected: React.PropTypes.object.isRequired,
        action: React.PropTypes.object.isRequired,
        sound: React.PropTypes.object.isRequired
    };

    constructor(props) {
		
        super(props);

        let celebs = {}, posters = {};
        let numOfItems = this.props.items.length;
        for (let i = 0; i < numOfItems; ++i) {
            let personId = this.props.items[i];
            celebs[personId] = Defaults.Credit.Empty;
            posters[personId] = Defaults.Photo.Portrait;
        }
		
        let widths = new Array(numOfItems).fill(2);
        widths.push(2.36);
        
        this.state = {
            celebs,
            posters,
            widths,
            currRow: this.props.selected.row,
            currCol: this.props.selected.cols[this.props.selected.row],
            scrollX: 0,
            position: 'right'
        };
    }

    shouldComponentUpdate(nextProps, nextState) {

        // Celebs available
        if (isEmptyObject(this.props.celebs) && !isEmptyObject(nextProps.celebs)) {
            if (hasErrorObject(nextProps.celebs)) {
                console.error("CarouselCelebs.shouldComponentUpdate(): error=" + nextProps.celebs.err);
            } else {
                nextState.celebs = nextProps.celebs;
                nextState.posters = {};
                for (let i = 0; i < this.props.items.length; ++i) {
                    let personId = this.props.items[i];
                    nextState.posters[personId] = {
                        height: '200',
                        width: '300',
                        url: nextProps.celebs[personId].photo
                    }
                }
            }
        }

        let suppressSound = false;
        if (this.props.action.id !== nextProps.action.id) {
            let action = nextProps.action;
            let volume = this.props.menuView.settings.audio.selected;
            switch (action.type) {
                case NOOP:
                    break;
                case KEYBOARD:
                    switch (action.event.direction) {
                        case 'i':
                        // Case 'v':
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
                        console.log("CarouselCelebs.shouldComponentUpdate(): CLICK action not defined");
                        this.props.getSoundAction(SoundTypes.Error_Alert, volume);
                        suppressSound = true;
                    } else {
                        this.props.dispatchAction(action);
                    }
                    break;
                case REC:
                    console.log("CarouselCelebs.shouldComponentUpdate(): REC action for Person is not defined");
                    this.props.getSoundAction(SoundTypes.Error_Alert, volume);
                    suppressSound = true;
                    break;
                default:
                    break;
            }
        }

        // Process sound
        if (this.props.sound.id !== nextProps.sound.id && !suppressSound) {
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

        let carouselType = 'Person';

        let self = this;        
        return (
            <div className="carousel-wrap">
                <div className="carousel" style={greyStyle}>
                    <label className={labelClass}>{carouselTitle}</label>
                    <ul style={calStyle}>
                        <ActionLinks actionLinks={actionLinks} active={isActiveCarousel && activeCol === 0} />
                        {
                            _.map(this.props.items, (personId, index) => {
                                let active = (isActiveCarousel && ((index + 1) === activeCol));
                                let expanded = isCabActive;
                                let isCabOn = (active & expanded);

                                let celeb = self.state.celebs[personId];
                                let poster = self.state.posters[personId];
                                let data = { celeb, poster };

                                // determine the width of the poster
                                let width = 2.230;

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
        }
    };
};

const mapDispatchToProps = dispatch => {
    return {
        dispatchAction: bindActionCreators(dispatchAction, dispatch),
        enableCAM: bindActionCreators(enableCAM, dispatch),
        getSoundAction: bindActionCreators(getSoundAction, dispatch),
        loadCommonInfoPage: bindActionCreators(loadCommonInfoPage, dispatch),
        requestCancelSeries: bindActionCreators(requestCancelSeries, dispatch)
    };
};

const attributes = {
    maxNumOfAttempts: 5,
    celebs: ['personId', 'firstName', 'lastName', 'gender', 'birthPlace', 'photo', 'biography'],
    onActive: true
};

const enhance = compose(
    withNavigation(attributes.onActive),
    withCelebs(attributes.celebs, attributes.maxNumOfAttempts),
    connect(mapStateToProps, mapDispatchToProps)
);

export default enhance(CarouselCelebs);