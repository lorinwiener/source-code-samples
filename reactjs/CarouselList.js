import React from 'react';
import {bindActionCreators} from 'redux';
import {connect} from 'react-redux';
import _ from 'lodash';
import shortid from 'shortid';

// import Carousel from './Carousel';
import CarouselCelebs from './CarouselCelebs';
import CarouselChannels from './CarouselChannels';
import CarouselEvents from './CarouselEvents';
import CarouselPlaylist from './CarouselPlaylist';

import {withNavigation} from '../../../enhancers/Navigation';

import {adjustVolume, dispatchAction, updateCarouselIndex} from '../../../actions/actions';

import {compose} from '../../../constants/Utils';

import {Menu} from '../../../constants/UIConfig';

class CarouselList extends React.Component {

    static propTypes = {
        // from parent component
        index: React.PropTypes.number.isRequired,
        numOfCarousels: React.PropTypes.number.isRequired,
        metadata: React.PropTypes.array.isRequired,
        listOfListOfItems: React.PropTypes.array.isRequired,
        listOfListOfActions: React.PropTypes.array.isRequired,
        // animate: React.PropTypes.string.isRequired,
        active: React.PropTypes.bool.isRequired,
        // from withNavigation
        selected: React.PropTypes.object.isRequired,
        action: React.PropTypes.object.isRequired,
        sound: React.PropTypes.object.isRequired
    };

    constructor(props) {
        super(props);
        let list = [];
        for (let i = 0; i < this.props.numOfCarousels; i++) {
            list.push({
                id: shortid.generate(),
                name: this.props.metadata[i].name,
                type: this.props.metadata[i].type,
                orientation: this.props.metadata[i].orientation,
                listOfItems: this.props.listOfListOfItems[i],
                listOfActions: this.props.listOfListOfActions[i]
            });
        }
        this.state = {
            tabIndex: this.props.index,
            carouselIndex: this.props.selected.row,
            carousels: list
        };
        // Sample state:
        // {
        //      "tab": 1,
        //      "carousels": [{
        //              "id":"By6IMwkFg",
        //              "name":"DVR Recordings",
        //              "type":"Program",
        //              "orientation":"Mixed",
        //              "listOfItems":["MV000821470000","MV006159310000","MV006744380000","EP015676680145","MV000907030000","MV000883000000","MV000317690000","MV000225140000","MV000340190000","MV001938010000"],
        //              "listOfActions":["All Recordings"]
        //          }, {
        //              "id":"HylaLMwyFx",
        //              "name":"Watchlist",
        //              "type":"Program",
        //              "orientation":"Mixed",
        //              "listOfItems":["MV000883000000","MV000225140000","MV000340190000","MV001938010000","MV006798690000"],
        //              "listOfActions":["View All"]
        //          }, {
        //              "id":"B1bTIzwktl",
        //              "name":"Digital Locker",
        //              "type":"Program",
        //              "orientation":"Mixed",
        //              "listOfItems":["MV000315670000","MV008574790000","MV007910620000","MV008778450000","MV002062560000","MV008684380000","MV000852330000","MV008778200000","MV008378230000","MV007821340000"],
        //              "listOfActions":["View All"]
        //          }
        //      ]
        // }
    }

    shouldComponentUpdate(nextProps, nextState) {
        //if (this.props.action.id !== nextProps.action.id) {
        //    let action = nextProps.action;
        //    switch (action.type) {
        //        default:
        //            this.props.dispatchAction(action);
        //            break;
        //    }
        //}
        if (this.props.sound.id !== nextProps.sound.id) {
            let volume = this.props.menuView.settings.audio.selected;
            this.props.dispatchAction(adjustVolume(nextProps.sound, volume));
        }
        let currCarouselIndex = this.state.carouselIndex;
        let nextCarouselIndex = nextProps.selected.row;
        if (currCarouselIndex !== nextCarouselIndex) {
            nextState.carouselIndex = nextCarouselIndex;
            this.props.updateCarouselIndex(nextCarouselIndex);
        }
        return true;
    }

    render() {
        let activeIndex = (this.props.active) ? this.props.selected.row : -1;
        let listClass = "carouselList "; //+ this.props.animate;
        let tabIndex = this.state.tabIndex;
        let self = this;
        return (
            <div className={listClass}>
                {_.map(this.state.carousels, (carousel, index) => {
                    let currCarouselName = carousel.name;
                    let nextCarouselName = ((index + 1) === self.state.carousels.length) ?
                            '' : self.state.carousels[index + 1].name;
                    let currCarouselActive = activeIndex === index;

                    // Tab: On Now, Carousel: DVR Recordings
                    if (tabIndex === Menu.Tab.MyLibrary && index === 0) {
                        let Initial = { row: 0, col: 1 };
                        let Map = [ 12 ]; // for now, hard code to 10 playlist items + 2 action
                        let StopPropagation = false;
                        return (
                            <CarouselPlaylist Initial={Initial} Map={Map} StopPropagation={StopPropagation}
                                              key={carousel.id}
                                              carousel={tabIndex}
                                              type={carousel.type}
                                              index={index}
                                              orientation={carousel.orientation}
                                              currCategory={currCarouselName}
                                              nextCategory={nextCarouselName}
                                              active={currCarouselActive}
                                              items={carousel.listOfItems}
                                              actions={carousel.listOfActions} />);
                    }

                    let Initial = { row: 0, col: 1 };
                    let Map = [ carousel.listOfItems.length + 2 ];
                    let StopPropagation = false;
                    switch (carousel.type) {
                        case 'Program':
                            return (
                                <CarouselEvents Initial={Initial} Map={Map} StopPropagation={StopPropagation}
                                                eventIds={carousel.listOfItems}
                                                key={carousel.id}
                                                carousel={tabIndex}
                                                index={index}
                                                orientation={carousel.orientation}
                                                currCategory={currCarouselName}
                                                nextCategory={nextCarouselName}
                                                active={currCarouselActive}
                                                items={carousel.listOfItems}
                                                actions={carousel.listOfActions}/>);
                        case 'Person':
                            return (
                                <CarouselCelebs Initial={Initial} Map={Map} StopPropagation={StopPropagation}
                                                personIds={carousel.listOfItems}
                                                key={carousel.id}
                                                carousel={tabIndex}
                                                index={index}
                                                orientation={carousel.orientation}
                                                currCategory={currCarouselName}
                                                nextCategory={nextCarouselName}
                                                active={currCarouselActive}
                                                items={carousel.listOfItems}
                                                actions={carousel.listOfActions}/>);
                        case 'Channel':
                            return (
                                <CarouselChannels Initial={Initial} Map={Map} StopPropagation={StopPropagation}
                                                  channelIds={carousel.listOfItems}
                                                  key={carousel.id}
                                                  carousel={tabIndex}
                                                  index={index}
                                                  orientation={carousel.orientation}
                                                  currCategory={currCarouselName}
                                                  nextCategory={nextCarouselName}
                                                  active={currCarouselActive}
                                                  items={carousel.listOfItems}
                                                  actions={carousel.listOfActions}/>);
                        default:
                            console.error("CarouselList.render(): unknown carousel type = " + carousel.type);
                            return null
                    }
                })}
            </div>
        )
    }
}

const mapStateToProps = (store) => {
    return {
        menuView: {
            tabIndex: store.events.menuView.tabIndex,
            carouselIndex: store.events.menuView.carouselIndex,
            settings: {
                audio: {
                    selected: store.events.menuView.settings.audio.selected
                }
            }
        }
    };
};

const mapDispatchToProps = dispatch => {
    return {
        dispatchAction: bindActionCreators(dispatchAction, dispatch),
        updateCarouselIndex: bindActionCreators(updateCarouselIndex, dispatch)
    };
};

const onActive = true;

const enhance = compose(
    withNavigation(onActive),
    connect(mapStateToProps, mapDispatchToProps)
);

export default enhance(CarouselList);
