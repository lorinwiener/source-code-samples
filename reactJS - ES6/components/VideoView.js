'use strict';

import React, {Component, PropTypes} from 'react';
import {bindActionCreators} from 'redux';
import {connect} from 'react-redux';

import {
    compose,
    findVideoWithId
} from '../../constants/Utils.js';

import {withObserver} from '../../enhancers/Remote';

import {BookingHelper} from '../../constants/BookingUtils';

import {KEYBOARD, REC} from '../../constants/constants';

import {
    enableCAM, disableCAM,
    requestCancelSeries,
    dispatchAction,
    updatePrimaryVideoTimestamp,
    updatePrimaryVideoState,
    clearTrickplay,
    fetchVideos,
    scheduleRecording,
    scheduleSeriesRecording
} from '../../actions/actions';

import {
    Context,
    Defaults,
    State,
    Trickplay,
    Video
} from '../../constants/UIConfig';

class VideoView extends Component {
    /**
     * Constructor
     * @param props
     */
    constructor(props) {
        super(props);

        // Video
        this.loadVideo = this.loadVideo.bind(this);
        this.playVideo = this.playVideo.bind(this);
        this.jumpToPosition = this.jumpToPosition.bind(this);
        this.changeSpeed = this.changeSpeed.bind(this);
        this.resumeVideo = this.resumeVideo.bind(this);
        this.pauseVideo = this.pauseVideo.bind(this);
        this.muteAudio = this.muteAudio.bind(this);
        this.unmuteAudio = this.unmuteAudio.bind(this);
        this.currentTime = this.currentTime.bind(this);

        // Video callback functions
        this.onTimeUpdate = this.onTimeUpdate.bind(this);
        this.onPlay = this.onPlay.bind(this);
        this.onPlaying = this.onPlaying.bind(this);
        this.onSeeked = this.onSeeked.bind(this);
        this.onPause = this.onPause.bind(this);
        this.onEnded = this.onEnded.bind(this);
        this.onError = this.onError.bind(this);
        this.onRateChange = this.onRateChange.bind(this);

        this.reloadVideo = false;
        this.loadAndWait = false;
        this.resumePlay = -1;
        this.numOfTimeUpdates = 0;

        // Rewind
        this.rewindScheduled = false;
        this.rewind = this.rewind.bind(this);
        this.scheduleRewind = this.scheduleRewind.bind(this);
        this.cancelRewind = this.cancelRewind.bind(this);

        // Fast forward
        this.fastForwardScheduled = false;
        this.fastForward = this.fastForward.bind(this);
        this.scheduleFastForward = this.scheduleFastForward.bind(this);
        this.cancelFastForward = this.cancelFastForward.bind(this);

        // Dismiss progress bar
        this.clearScheduled = false;
        this.clear = this.clear.bind(this);
        this.scheduleClear = this.scheduleClear.bind(this);
        this.cancelClear = this.cancelClear.bind(this);
    }

    componentWillMount() {
        this.props.fetchVideos();
    }

    //	VideoView is mounted, play the video
    componentDidMount() {
        this.playVideo();
    }

    //	VideoView was updated, reload the video if needed
    componentDidUpdate() {
        if (this.reloadVideo) {
            // always let first time update through
            this.numOfTimeUpdates = 10;
            this.loadVideo();
            this.playVideo();
            this.reloadVideo = false;
        } else if (this.loadAndWait) {
            // always let first time update through
            this.numOfTimeUpdates = 10;
            this.loadVideo();
            this.loadAndWait = false;
        } else if (this.resumePlay >= 0) {
            this.playVideo(this.resumePlay);
            this.resumePlay = -1;
        }
    }

    /**
     * Check if component should be updated
     * @param nextProps
     * @param nextState
     * @returns {boolean}
     */
    shouldComponentUpdate(nextProps, nextState) {

        let currVideoState = this.props.videoView.state.video;
        let nextVideoState = nextProps.videoView.state.video;

        let currVideoId = this.props.videoView.main.videoId;
        let nextVideoId = nextProps.videoView.main.videoId;

        // Check if there is a request to play/pause/scrub/jump/trickplay
        if (nextVideoState !== currVideoState) {
            switch (nextVideoState) {
                case State.Video.WatchImmediately:
                    this.reloadVideo = (nextVideoId !== currVideoId);
                    break;
                case State.Video.LoadAndWait:
                    this.loadAndWait = (nextVideoId !== currVideoId);
                    break;
                case State.Video.WatchFromPosition:
                    let position = 0;
                    if (nextProps.videoView.secondary.position > 0) {
                        position = nextProps.videoView.secondary.position;
                    }
                    this.resumePlay = position;
                    break;
                case State.Video.Resume:
                    this.refs.video.playbackRate = 1;
                    this.resumeVideo();
                    this.unmuteAudio();
                    this.scheduleClear(Trickplay.Timeout.Immediately);
                    break;
                case State.Video.Play:
                    this.playVideo();
                    break;
                case State.Video.Pause:
                    this.cancelClear();
                    this.pauseVideo();
                    break;
                case State.Video.Scrub:
                    this.scheduleClear(Trickplay.Timeout.Immediately);
                    this.jumpToPosition(Math.floor(this.props.infoView.trickplay.preview.position));
                    break;
                case State.Video.JumpForward:
                    this.scheduleClear(Trickplay.Timeout.Indicator);
                    this.jumpToPosition(this.currentTime() + Trickplay.Jump.Distance);
                    break;
                case State.Video.JumpBackward:
                    this.scheduleClear(Trickplay.Timeout.Indicator);
                    this.jumpToPosition(this.currentTime() - Trickplay.Jump.Distance);
                    break;
                case State.Video.FastForward:
                    this.changeSpeed('FFW');
                    break;
                case State.Video.FastRewind:
                    this.changeSpeed('REW');
                    break;
                default:
                    break;
            }
        }

        if (this.props.action.id !== nextProps.action.id) {
            let action = nextProps.action;
            let volume = this.props.menuView.settings.audio.selected;
            switch (action.type) {
                case KEYBOARD:
                    switch (action.event.direction) {
                        case 'i':
                        case 'v':
                            if (!nextProps.contextualView.active) {
                                this.props.enableCAM(Context.Video);
                            }
                            break;
                        default:
                            this.props.dispatchAction(action);
                            break;
                    }
                    break;
                case REC:
                    let currVideoSpeed = this.props.videoView.state.speed;
                    if ((currVideoState === State.Video.Playing || currVideoState === State.Video.Play || currVideoState === State.Video.Resume) && currVideoSpeed === 1) {
                        let tmsId = this.props.videoView.main.tmsId;
                        let isScheduled = BookingHelper.isScheduledById(tmsId, this.props.todos.list);
                        let isRecurring = BookingHelper.isRecurringById(tmsId, this.props.todos.list);
                        if (isScheduled && isRecurring) {
                            this.props.requestCancelSeries(tmsId);
                        } else {
                            let request = {
                                channel: {
                                    id: this.props.videoView.main.channelId,
                                    major: this.props.videoView.main.major
                                },
                                schedule: {
                                    startTime: this.props.videoView.startTime,
                                    duration: this.props.videoView.duration
                                },
                                program: {
                                    tmsId: tmsId
                                },
                                active: true
                            };
                            this.props.scheduleRecording(request, volume);
                        }
                    } else {
                        console.log("VideoView.shouldComponentUpdate(): Unable to process REC during trickplay, state=" +
                                currVideoState + ", speed=" + currVideoSpeed);
                    }
                    break;
                default:
                    this.props.dispatchAction(action);
                    break;
            }
        }

        // Always return yes
        return true;
    }

    /**
     * Retrieve current playback position
     * @returns {VideoView.currentTime|*|function(this:VideoView)|number|Number|r}
     */
    currentTime() {
        return this.refs.video.currentTime;
    }

    /**
     * Load video
     */
    loadVideo() {
        this.refs.video.load();
    }

    /**
     * Play video (set playback rate to 1x, unmute audio)
     */
    playVideo(position = 0) {
        if (this.props.videoView.state.video === State.Video.Playing &&
            this.props.videoView.state.speed === 1 && !this.reloadVideo) {
            this.onPlaying();
            this.scheduleClear();
        }
        else {
            this.refs.video.playbackRate = 1;
            this.refs.video.currentTime = position;
            this.refs.video.play();

            this.unmuteAudio();

            this.scheduleClear(Trickplay.Timeout.Immediately);
            this.cancelRewind();
        }
    }

    /**
     * Resume video at current playback rate
     */
    resumeVideo() {
        this.refs.video.play();
    }

    /**
     * Pause video
     */
    pauseVideo() {
        if (this.props.videoView.state.video === State.Video.Paused) {
            this.onPause();
        } else {
            this.refs.video.pause();
        }
    }

    /**
     * Mute audio
     */
    muteAudio() {
        // this.refs.video.mute();
        this.refs.video.muted = true;
    }

    /**
     * Unmute audio
     */
    unmuteAudio() {
        // this.refs.video.unmute();
        this.refs.video.muted = false;
    }

    /**
     * Scrub to new position
     * @param position
     */
    jumpToPosition(position) {
        // simply resume video
        if (position < 0) {
            this.refs.video.playbackRate = 1;
            this.resumeVideo();
            this.unmuteAudio();
        }
        // Cannot jump to a position outside program boundary
        else if (position > this.props.videoView.duration) {
            console.error("VideoView.jumpToPosition(" + position + "): valid range [0," +
                this.props.videoView.duration + "]");
            return;
        }
        // Set playback rate to 1x and jump to new position
        else {
            this.refs.video.playbackRate = 1;
            this.refs.video.currentTime = position;
            this.unmuteAudio();
        }
    }

    /**
     * Trickplay
     * @param direction
     */
    changeSpeed(direction) {
        // Retrieve current playback rate
        var currentRate = this.refs.video.playbackRate;

        // Calculate new playback rate
        var newRate = currentRate;
        if (currentRate > 0) {
            switch (direction) {
                case 'REW':
                    newRate /= 2;
                    break;
                case 'FFW':
                    newRate *= 2;
                    break;
            }
        }
        else if (currentRate < 0) {
            switch (direction) {
                case 'REW':
                    newRate *= 2;
                    break;
                case 'FFW':
                    newRate /= 2;
                    break;
            }
        }

        // Check speed limit
        if (newRate > Trickplay.Max.FastForward) {
            newRate = Trickplay.Max.FastForward;
        }
        else if (newRate < Trickplay.Max.FastRewind) {
            newRate = Trickplay.Max.FastRewind;
        }

        // Handle direction change
        if (0 < newRate && newRate < 1) {
            newRate = -2;
        }
        else if (-1 <= newRate && newRate < 0) {
            newRate = 1;
        }

        // Mute audio during trickplay and display progress bar
        if (newRate !== 1) {
            this.muteAudio();
            this.cancelClear();
        }
        // Unmute audio when playing at 1x and dismiss progress after 5s
        else {
            this.unmuteAudio();
            this.scheduleClear(Trickplay.Timeout.Immediately);
        }

        if (newRate !== currentRate) {
            this.refs.video.playbackRate = newRate;
            this.resumeVideo();
        }
        else {
            this.props.updateVideoState(State.Video.Playing, currentRate);
        }
    }

    /**
     * Time update callback
     * @param event
     */
    onTimeUpdate(event) {
         // If progress bar is visible then always propagate the event for smooth
         if (this.props.infoView.trickplay.visible) {
             // console.log("VideoView.onTimeUpdate(): " + this.refs.video.playbackRate + "x");
             this.props.updateCurrentTime(event.target.currentTime, event.target.duration);
             this.numOfTimeUpdates = 0;
         }
         // Otherwise every 10th event to not flood the reducer
         else {
             this.numOfTimeUpdates++;
             if (this.numOfTimeUpdates > Defaults.SuppressTimeUpdates) {
                 // console.log("VideoView.onTimeUpdate(): " + this.refs.video.playbackRate + "x");
                 this.props.updateCurrentTime(event.target.currentTime, event.target.duration);
                 this.numOfTimeUpdates = 0;
             }
         }
    }

    /**
     * Starting playing callback
     */
    onPlay() {
        //console.log("VideoView.onPlay(): " + this.refs.video.playbackRate + "x");
        this.props.updateVideoState(State.Video.Playing, this.refs.video.playbackRate);
    }

    /**
     * Resumed playing callback
     */
    onPlaying() {
        //console.log("VideoView.onPlaying(): " + this.refs.video.playbackRate + "x");
        this.props.updateVideoState(State.Video.Playing, this.refs.video.playbackRate);
    }

    /**
     * Paused callback
     */
    onPause() {
        //console.log("VideoView.onPause(): " + this.refs.video.playbackRate + "x");
        this.props.updateVideoState(State.Video.Paused, this.refs.video.playbackRate);
    }

    /**
     * Jumped to new position callback - resume playback
     */
    onSeeked() {
        this.resumeVideo();
    }

    /**
     * Playback ended callback
     */
    onEnded() {
        this.props.updateVideoState(State.Video.Stopped, this.refs.video.playbackRate);
    }

    /**
     * Playback rate changed callback
     */
    onRateChange() {
        var playbackRate = this.refs.video.playbackRate;

        // Positive speed is true playback speed, report it back
        if (playbackRate > 0) {
            // Cancel rewind task if clearScheduled
            this.cancelRewind();

            if (playbackRate < Trickplay.FastForward.Boost) {
                this.cancelFastForward();
            }
            else {
                this.scheduleFastForward();
            }
        }

        // Negative speed needs to be simulated
        else {
            this.rewind();
            this.scheduleRewind();
        }

        this.props.updateVideoState(State.Video.Playing, playbackRate);
    }

    fastForward() {
        var rate = this.refs.video.playbackRate;

        // Cancel if current rate is less than 8
        if (rate < Trickplay.FastForward.Boost) {
            this.cancelFastForward();
            return;
        }

        // Calculate how much to jump back
        var newPosition = this.refs.video.currentTime + (rate / 8);
        if (newPosition > this.props.videoView.duration) {
            newPosition = this.props.videoView.duration;
        }

        // Now perform the jump
        this.refs.video.currentTime = newPosition;

        if (newPosition === 0 || newPosition === this.props.videoView.duration) {
            this.refs.video.playbackRate = 1;
            this.unmuteAudio();
            this.scheduleClear();
        }
    }

    /**
     * Schedule fast forward task (cancel previous task if scheduled)
     * @param interval
     */
    scheduleFastForward(interval = Trickplay.FastForward.Granularity) {
        this.cancelFastForward();
        this.fastForwardTask = setInterval(this.fastForward, interval);
        this.fastForwardScheduled = true;
    }

    /**
     * Cancel fast forward task if scheduled
     */
    cancelFastForward() {
        if (this.fastForwardScheduled) {
            clearTimeout(this.fastForwardTask);
            this.fastForwardScheduled = false;
        }
    }

    /**
     * Simulate rewind by jumping back
     */
    rewind() {
        var rate = this.refs.video.playbackRate;

        // If FFW then cancel the rewind task and return
        if (rate > 0) {
            if (this.rewindTask !== null) {
                clearTimeout(this.rewindTask);
            }
            return;
        }

        // Calculate how much to jump back
        var newPosition = this.refs.video.currentTime + (rate / 8);
        if (newPosition < 0) {
            newPosition = 0;
        }

        // Now perform the jump
        this.refs.video.currentTime = newPosition;

        if (newPosition === 0) {
            this.refs.video.playbackRate = 1;
            this.unmuteAudio();
            this.scheduleClear();
        }
    }

    /**
     * Schedule rewind task (cancel previous task if scheduled)
     * @param interval
     */
    scheduleRewind(interval = Trickplay.Rewind.Granularity) {
        this.cancelRewind();
        this.rewindTask = setInterval(this.rewind, interval);
        this.rewindScheduled = true;
    }

    /**
     * Cancel rewind task if scheduled
     */
    cancelRewind() {
        if (this.rewindScheduled) {
            clearTimeout(this.rewindTask);
            this.rewindScheduled = false;
        }
    }

    /**
     * Send action to clear trickplay bar
     */
    clear() {
        this.props.clearTrickplay();
        this.clearScheduled = false;
    }

    /**
     * Schedule clear task (cancel previous task if scheduled)
     * @param wait
     */
    scheduleClear(wait = Trickplay.Timeout.ProgressBar) {
        this.cancelClear();
        this.clearTask = setTimeout(this.clear, wait);
        this.clearScheduled = true;
    }

    /**
     * Cancel clear task if scheduled
     */
    cancelClear() {
        if (this.clearScheduled) {
            clearTimeout(this.clearTask);
            this.clearScheduled = false;
        }
    }

    /**
     * Render!
     * @returns {XML}
     */
    render() {
        // Audio is on
        var isMute = false;

        // Determine if video needs to be resized to fit PIG
        var videoStyle = "video-view focusable";
        if (!this.props.infoView.visible && this.props.audioVideoSettings.videoMode === Video.Mode.Partial) {
            videoStyle += " zoomed";
        }

        // Find matching video
        let videoSrc = null;
        let video = findVideoWithId(this.props.videoView.main.videoId);
        if (video !== null) {
            videoSrc = video.src;
        }

        return (
            <div id="videoCont" className="video-cont">
                <video id="video-view" ref="video" className={videoStyle} loop muted={isMute}
                       onTimeUpdate={this.onTimeUpdate}
                       onPlaying={this.onPlaying}
                       onPlay={this.onPlay}
                       onPause={this.onPause}
                       onSeeked={this.onSeeked}
                       onEnded={this.onEnded}
                       onError={this.onError}
                       onRateChange={this.onRateChange}>
                    <source src={videoSrc} type='video/mp4'/>
                </video>
            </div>
        );
    }
}

const mapStateToProps = store => {
    return {
        audioVideoSettings: {
            videoMode: store.events.audioVideoSettings.videoMode,
        },
        videoView: {
            startTime: store.events.videoView.startTime,
            duration: store.events.videoView.duration,
            main: {
                videoId: store.events.videoView.main.videoId,
                channelId: store.events.videoView.main._channelId,
                major: store.events.videoView.main._major,
                tmsId: store.events.videoView.main._tmsId
            },
            state: {
                video: store.events.videoView.state.video,
                speed: store.events.videoView.state.speed
            },
            secondary: {
                videoId: store.events.videoView.secondary.videoId,
                active: store.events.videoView.secondary.active,
                position: store.events.videoView.secondary.position
            }
        },
        contextualView: {
            active: store.events.contextualView.active,
            context: store.events.contextualView.context
        },
        infoView: {
            visible: store.events.infoView.visible,
            trickplay: {
                preview: {
                    position: store.events.infoView.trickplay.preview.position,
                    visible: store.events.infoView.trickplay.preview.visible
                },
                visible: store.events.infoView.trickplay.visible
            }
        },
        menuView: {
            settings: {
                audio: {
                    selected: store.events.menuView.settings.audio.selected
                }
            }
        },
        todos: {
            list: store.todos.list
        }
    };
};

const mapDispatchToProps = dispatch => {
    return {
        enableCAM: bindActionCreators(enableCAM, dispatch),
        disableCAM: bindActionCreators(disableCAM, dispatch),
        dispatchAction: bindActionCreators(dispatchAction, dispatch),
        updateVideoState: bindActionCreators(updatePrimaryVideoState, dispatch),
        updateCurrentTime: bindActionCreators(updatePrimaryVideoTimestamp, dispatch),
        clearTrickplay: bindActionCreators(clearTrickplay, dispatch),
        fetchVideos: bindActionCreators(fetchVideos, dispatch),
        requestCancelSeries: bindActionCreators(requestCancelSeries, dispatch),
        scheduleRecording: bindActionCreators(scheduleRecording, dispatch),
        scheduleSeriesRecording: bindActionCreators(scheduleSeriesRecording, dispatch)
    };
};

const enhance = compose(
    withObserver(),
    connect(mapStateToProps, mapDispatchToProps)
);

export default enhance(VideoView);