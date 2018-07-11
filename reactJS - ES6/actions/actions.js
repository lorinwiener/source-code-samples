'use strict';

import * as cont from '../constants/constants';

import {
    getVolumeLevel,
    ID
} from '../constants/Utils';

import {
    SoundEffects,
    Trickplay
} from '../constants/UIConfig';

import menu from '../api/menu';
import channelsByIsland from '../api/channelsByIsland';
import channels from '../api/channels';
import shows from '../api/shows';
import videos from '../api/videos';
import {SoundTypes} from '../api/sounds';
import type, {Action, TapClickSwipeOnTouchEvent} from './types';

export function dispatchAction(action) {
    return action;
}

//	SOUNDS
export function getSoundAction(sound: string, volume = SoundEffects.Volume.Muted): Action {
    return {
        id: ID.next().value,
        type: cont.SOUND_ACTION,
        meta: {
            sound: sound,
            volume: getVolumeLevel(volume)
        }
    };
}
export function adjustVolume(action: Action, volume: number): Action {
    if (action.meta && action.meta.sound) {
        let newVol = getVolumeLevel(volume);
        if (!action.meta.volume || action.meta.volume !== newVol) {
            action.meta.volume = newVol;
        }
    }
    return action;
}

//	GLOBAL
export function getVoidAction(): Action {
    return {
        type: cont.VOID_ACTION
    }
}
export function getActionFromKeyEvent(aType: string, aEvent: TapClickSwipeOnTouchEvent): Action {
    return {
        type: aType,
        event: aEvent
    }
}
export function getTrickplayAction(aType, aPayload = {}): Action {
    return {
        type: aType,
        payload: aPayload
    };
}

//	MAIN BODY
export function toggleMenu() {
    return {
        type: cont.TOGGLE_MENU
    }
}

// COMMON INFO PAGE
export function loadCommonInfoPage(event) {
    return {
        type: cont.LOAD_COMMON_INFO_PAGE,
        event: event
    };
}
export function toggleRecordOptions() {
    return {
        type: cont.TOGGLE_RECORD_OPTIONS
    };
}

//	RECORDING
export function scheduleRecording(request, volume = SoundEffects.Volume.Muted) {
    return {
        type: cont.SCHEDULE_RECORDING,
        payload: request,
        meta: {
            sound: SoundTypes.Record,
            volume: getVolumeLevel(volume)
        }
    };
}
export function scheduleSeriesRecording(request, volume = SoundEffects.Volume.Muted) {
    return {
        type: cont.SCHEDULE_SERIES_RECORDING,
        payload: request,
        meta: {
            sound: SoundTypes.Record_Series,
            volume: getVolumeLevel(volume)
        }
    };
}
export function updateRecording(tmsId, options) {
    return {
        type: cont.UPDATE_RECORDING,
        tmsId: tmsId,
        options: options
    };
}
export function cancelRecording(tmsId, volume = SoundEffects.Volume.Muted) {
    return {
        type: cont.CANCEL_RECORDING,
        payload: {
            program: { tmsId }
        },
        meta: {
            sound: SoundTypes.Delete,
            volume: getVolumeLevel(volume)
        }
    };
}
export function cancelSeriesRecording(tmsId, volume = SoundEffects.Volume.Muted) {
    return {
        type: cont.CANCEL_SERIES_RECORDING,
        payload: {
            program: { tmsId }
        },
        meta: {
            sound: SoundTypes.Delete_Series,
            volume: getVolumeLevel(volume)
        }
    };
}
export function requestCancelSeries(tmsId) {
    return {
        type: cont.CANCEL_SERIES_REQ,
        tmsId: tmsId
    };
}
export function confirmCancelSeries(tmsId, cancelSeries = false, undoCancel = false, volume = SoundEffects.Volume.Muted) {
    let sound = SoundTypes.Delete;
    if (cancelSeries) {
        sound = SoundTypes.Delete_Series;
    } else if (undoCancel) {
        sound = SoundTypes.Undo;
    }
    return {
        type: cont.CANCEL_SERIES_ACK,
        tmsId: tmsId,
        undoCancel: undoCancel,
        cancelSeries: cancelSeries,
        meta: {
            sound,
            volume: getVolumeLevel(volume)
        }
    };
}

//	SEARCH
export function voiceSearchStart() {
    return {
        type: cont.MIC,
        enable: true
    }
}
export function voiceSearchStop() {
    return {
        type: cont.MIC,
        enable: false
    }
}

export function updateSearchKeyword(keyword) {
    return {
        type: cont.UPDATE_KEYWORD,
        keyword: keyword
    }
}

//	MENU
export function updateTabIndex(index) {
    return {
        type: cont.UPDATE_TAB_INDEX,
        index: index
    };
}
export function updateNumOfCarousels(count) {
    return {
        type: cont.UPDATE_NUM_OF_CAROUSELS,
        count: count
    }
}
export function updateCarouselIndex(index) {
    return {
        type: cont.UPDATE_CAROUSEL_INDEX,
        index: index
    };
}
export function updateSettings(option, selected) {
    return {
        type: cont.UPDATE_SETTINGS,
        option: option,
        selected: selected
    };
}

// CONTEXTUAL MENU
export function disableCAM() {
    return {
         type: cont.DISABLE_CAM
    };
}
export function enableCAM(context) {
    return {
        type: cont.ENABLE_CAM,
        context: context
    };
}

// PLAYLIST
export function buildPlaylistModel(playlist) {
    return {
        type: cont.BUILD_PLAYLIST_MODEL,
        playlist: playlist
    }
}
export function updatePlaylistModel(playlist) {
    return {
        type: cont.UPDATE_PLAYLIST_MODEL,
        playlist: playlist
    }
}
export function togglePlaylist() {
    return {
        type: cont.TOGGLE_PLAYLIST
    }
}
export function updatePlaylistState(state) {
    return {
        type: cont.UPDATE_PLAYLIST_STATE,
        state: state
    }
}

// MY TV 
export function updatePrimaryVideoTimestamp(aCurrentTime, aDuration) {
    return {
        type: cont.UPDATE_PRIMARY_VIDEO_TIMESTAMP,
        payload: {
            position: aCurrentTime,
            duration: aDuration
        }
    }
}
export function updatePrimaryVideoState(aState, aSpeed = 0) {
    return {
        type: cont.UPDATE_PRIMARY_VIDEO_STATE,
        state: aState,
        speed: aSpeed
    }
}
export function updateSecondaryVideoTimestamp(aVideoId, aPosition) {
    return {
        type: cont.UPDATE_SECONDARY_VIDEO_TIMESTAMP,
        videoId: aVideoId,
        position: aPosition
    }
}
export function updateSecondaryVideoState(aVideoId, aActive) {
    return {
        type: cont.UPDATE_SECONDARY_VIDEO_STATE,
        videoId: aVideoId,
        active: aActive
    }
}
export function clearTrickplay() {
    return {
        type: cont.CLEAR_TRICKPLAY
    }
}
export function fetchIcons() {
    return {
        type: cont.FETCH_ICONS,
        icons: [
            {
                icon: "interactive",
                text: "INTERACTIVE",
                action: Trickplay.Action.Interactive
            }, {
                icon: "cab",
                text: "CAB",
                action: Trickplay.Action.ContextualMenu
            }, {
                icon: "settings",
                text: "SETTINGS",
                action: Trickplay.Action.Settings
            }
        ]
    }
}

//	CHANNEL LIST
export function fetchChannelIslands() {
    return {
        type: cont.FETCH_CHANNEL_ISLANDS,
        channelIslands: channelsByIsland.channelIslands,
        categories: channelsByIsland.islands,
        channels: channels.channels
    }
}
export function fetchShows() {
    return {
        type: cont.FETCH_SHOWS,
        shows: shows.shows
    }
}
export function selectChannelIsland(aIndex) {
    return {
        type: cont.SELECT_CHANNEL_ISLAND,
        index: aIndex
    }
}

export function sendSettings(settings) {
    return {
        type: "SETTINGS",
        settings: settings
    }
}

export function fetchVideos() {
    return {
        type: cont.FETCH_VIDEOS,
        videos: videos.videos
    }
}