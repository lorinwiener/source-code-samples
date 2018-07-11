'use strict';

import React, {Component, PropTypes} from 'react';
import {bindActionCreators} from 'redux';
import {connect} from 'react-redux';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

import pgwsclient from '../../api/pgwsclient';

import VideoView from './VideoView';
import TouchView from './TouchView';
import SearchView from './search/SearchView';
import MenuView from './main_menu/MenuView';
import InfoView from './info_view/InfoView';
import PlaylistView from './playlist_view/PlaylistView';
import CommonInfoView from './common_info_view/CommonInfoView';
import RecordingCancelOverlay from './shared_components/RecordingCancelOverlay';

import {keysOnRemoteControlStart} from '../human_inputs/RemoteControlKeys';
import {touchOnRemoteControlStart} from '../human_inputs/RemoteControlTouch';

import {writePlaylist} from '../../reducers/reducer_helpers/PlaylistUtils';
import {makeCancelable} from '../../constants/Utils';
import {Menu} from '../../constants/UIConfig';

import {
    adjustVolume,
    dispatchAction
} from '../../actions/actions';

class Application extends Component {

    constructor(props) {
        super(props);
        this.resetPlaylist = this.resetPlaylist.bind(this);
        this.keysOnRemoteControlStop = null;
        this.touchOnRemoteControlStop = null;
    }

    componentWillMount() {
        const {dispatch} = this.props;
        this.keysOnRemoteControlStop = keysOnRemoteControlStart(dispatch);
        this.touchOnRemoteControlStop = touchOnRemoteControlStart(dispatch);

        if (this.props.menuView.settings.playlist.selected === Menu.Playlist.OnApplication) {
            this.resetPlaylist();
        }
    }

    shouldComponentUpdate(nextProps, nextState) {
        if (this.props.sound.id !== nextProps.sound.id && nextProps.sound.id !== -1) {
            let action = nextProps.sound;
            let volume = nextProps.menuView.settings.audio.selected;
            this.props.dispatchAction(adjustVolume(action, volume));
        }
        return true;
    }

    componentWillUnmount() {
        if (this.keysOnRemoteControlStop) {
            this.keysOnRemoteControlStop();
        }
        if (this.touchOnRemoteControlStop) {
            this.touchOnRemoteControlStop();
        }
    }

    render() {
        // Mount touch view only when visible
        let touchView = (this.props.touches.isVisible) ? <TouchView /> : null;
        let infoView = (this.props.infoView.visible) ? <InfoView /> : null;
        let searchView = (this.props.searchView.visible) ? <SearchView /> : null;
        let playlistView = (this.props.playlistView.visible) ? <PlaylistView /> : null;
        let commonInfoView = null;
        if (this.props.commonInfoView.visible) {
            commonInfoView = <CommonInfoView eventIds={this.props.commonInfoView.event.tmsId} />;
        }

        let menuView = null;
        if (this.props.menuView.visible) {
            let Initial = { row: 1, col: 0};
            let Map = [ 1, 1 ];
            let StopPropagation = true;
            menuView = <MenuView Initial={Initial} Map={Map} StopPropagation={StopPropagation} />;
        }

        let shadowStyle = (this.props.menuView.visible) ? "drop-shadow menu-active" : "drop-shadow";
        let cancelOsd = null;
        if (this.props.todos.next.pending) {
            let Map = [3];
            let StopPropagation = true;
            let Initial = {row: 0, col: 0};
            cancelOsd = <RecordingCancelOverlay Map={Map}
                                                StopPropagation={StopPropagation}
                                                Initial={Initial}
                                                tmsId={this.props.todos.next.tmsId} />;
        }

        let body = <div id="application" className="application OFF"/>;

        if (this.props.audioVideoSettings.power) {
            body = <div id="application" className="application">
                <VideoView />
                {searchView}
                {infoView}
                <ReactCSSTransitionGroup
                    transitionAppear={true}
                    transitionAppearTimeout={1000}
                    transitionEnterTimeout={1000}
                    transitionLeaveTimeout={1000}
                    transitionName="ngc-view">
                    {menuView}
                </ReactCSSTransitionGroup>
                {playlistView}
                {commonInfoView}
                {touchView}
                <div className={shadowStyle}></div>
                {cancelOsd}
            </div>;
        }

        return (body);
    }

    resetPlaylist() {
        console.log("********** Playlist Reset **********");
        this.promiseCount = makeCancelable(pgwsclient.getValue(['playlist', 'length']));
        this.promiseCount
            .promise
            .then(numOfItems => {
                let allIndices = [];
                for (let i = 0; i < numOfItems; i++) {
                    allIndices.push(i.toString());
                }
                writePlaylist(allIndices, allIndices);
            })
            .catch(error => {
                console.error("Application.resetPlaylist(): unable to reset playlist, error=" + JSON.stringify(error));
            });

    }
}

const mapStateToProps = store => {
    return {
        audioVideoSettings: {
            power: store.events.audioVideoSettings.power
        },
        searchView: {
            visible: store.events.searchView.visible
        },
        touches: {
            isVisible: store.touches.isVisible
        },
        menuView: {
            visible: store.events.menuView.visible,
            settings: {
                playlist: {
                    selected: store.events.menuView.settings.playlist.selected
                },
                audio: {
                    selected: store.events.menuView.settings.audio.selected
                }
            }
        },
        infoView: {
            visible: store.events.infoView.visible
        },
        playlistView: {
            visible: store.events.playlistView.visible
        },
        commonInfoView: {
            visible: store.events.commonInfoView.visible,
            event: {
                tmsId: store.events.commonInfoView.event.tmsId
            },
        },
        todos: {
            next: {
                pending: store.todos.next.pending,
                tmsId: store.todos.next.tmsId
            }
        },
        sound: store.events.sound
    };
};

const mapDispatchToProps = dispatch => {
    return {
        dispatchAction: bindActionCreators(dispatchAction, dispatch),
        dispatch: dispatch
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(Application);