'use strict';

import {
    CANCEL_SERIES_REQ,
    CANCEL_SERIES_ACK,
    CANCEL_RECORDING,
    CANCEL_SERIES_RECORDING,
    SCHEDULE_RECORDING,
    SCHEDULE_SERIES_RECORDING,
    UPDATE_RECORDING
} from '../constants/constants';

import {Defaults} from '../constants/UIConfig';

import {
    isEpisodic,
    getSeriesTmsId
} from '../constants/Utils';

const initialState = {
    list: {
         //One-shot:
         //
         // tmsId: {                // episodes TMS ID, e.g. EP001151270246
         //     recurring: false,
         //     active: Boolean,
         //     channel: {
         //         id: Number,
         //         major: Number
         //     },
         //     options: {
         //         schedule: Number
         //         keepUntil: Number,
         //         startExtension: Number,
         //         stopExtension: Number
         //     }
         // }
         //
         //
         //Recurring:
         //
         // tmsId: {                // series TMS ID, e.g. EP001151270000, matches EP001151270000, EP001151270001, ..., EP001151279999
         //     recurring: true,
         //     activeList: [],     // all episodes that are actively being recorded
         //     suppressionList: [] // all episodes that have been cancelled explicitly by the user
         //     channel: {
         //         id: Number,
         //         major: Number
         //     },
         //     options: {
         //         keepUntil: Number,
         //         keepAtMost: Number,
         //         recordEpisodes: Number,
         //         startExtension: Number,
         //         stopExtension: Number
         //     }
         // }
    },
    next: {
        pending: false,
        tmsId: null
    }
};

export default function todosReducer(state = initialState, action) {
    switch (action.type) {
        case CANCEL_SERIES_REQ: {
            if (state.next.pending) {
                console.error("todosReducer(): waiting for ACK - invalid action = " + JSON.stringify(action));
                return state;
            }
            let nextState = {...state};
            nextState.next.pending = true;
            nextState.next.tmsId = action.tmsId;
            return nextState;
        }

        case CANCEL_SERIES_ACK: {
            if (!state.next.pending) {
                console.error("todosReducer(): waiting for REQ - invalid action = " + JSON.stringify(action));
                return state;
            }
            let tmsId = state.next.tmsId;
            if (tmsId !== action.tmsId) {
                console.error("todosRedcuer(): TMS IDs do not match - waiting for " + tmsId +
                        " but received " + action.tmsId + " instead");
                return state;
            }
            // do nothing and dismiss OSD
            if (action.undoCancel) {
                let nextState = {...state};
                nextState.next.pending = false;
                nextState.next.tmsId = null;
                return nextState;
            }
            // cancel episode and/or series
            let key = (action.cancelSeries) ? getSeriesTmsId(tmsId) : tmsId;
            let nextState = cancelRecording(state, {
                program: {
                    tmsId: key
                }
            });
            nextState.next.pending = false;
            nextState.next.tmsId = null;
            return nextState;
        }

        case SCHEDULE_RECORDING:
            return scheduleRecording(state, action.payload);

        case SCHEDULE_SERIES_RECORDING:
            return scheduleRecording(state, action.payload);

        case CANCEL_RECORDING:
            return cancelRecording(state, action.payload);

        case CANCEL_SERIES_RECORDING:
            return cancelRecording(state, action.payload);

        case UPDATE_RECORDING:
            return updateRecording(state, action.tmsId, action.options);

        default:
            return state;
    }
}

/**
 * Update schedule recording options
 *
 * @param state
 * @param tmsId
 * @param options
 * @returns {*}
 */
function updateRecording(state, tmsId, options) {

    let booking = state.list[tmsId];
    if (booking) {
        let nextState = {...state};
        if (options.keepUntil >= 0) {
            nextState.list[tmsId].options.keepUntil = options.keepUntil;
        }
        if (options.startExtension >= 0) {
            nextState.list[tmsId].options.startExtension = options.startExtension;
        }
        if (options.stopExtension >= 0) {
            nextState.list[tmsId].options.stopExtension = options.stopExtension;
        }
        if (options.schedule >= 0) {
            nextState.list[tmsId].options.schedule = options.schedule;
        }
        return nextState;
    }

    if (isEpisodic(tmsId)) {
        let seriesId = getSeriesTmsId(tmsId);
        booking = state.list[seriesId];
        if (booking) {
            let nextState = {...state};
            if (options.keepUntil >= 0) {
                nextState.list[seriesId].options.keepUntil = options.keepUntil;
            }
            if (options.keepAtMost >= 0) {
                nextState.list[seriesId].options.keepAtMost = options.keepAtMost;
            }
            if (options.recordEpisodes >= 0) {
                nextState.list[seriesId].options.recordEpisodes = options.recordEpisodes;
            }
            if (options.startExtension >= 0) {
                nextState.list[seriesId].options.startExtension = options.startExtension;
            }
            if (options.stopExtension >= 0) {
                nextState.list[seriesId].options.stopExtension = options.stopExtension;
            }
            console.log("[RECORD] updateRecording(): Series options updated = " + JSON.stringify(nextState.list[seriesId].options));
            return nextState;
        }
    }

    console.error("[RECORD] updateRecording(): No bookings matching TMS ID " + tmsId + " found in the schedule");
    return state;
}

/**
 * Cancel scheduled recording
 *
 * @param state
 * @param request
 * @return {*}
 */
function cancelRecording(state, request) {
    console.log("[RECORD] cancelRecording(): request=" + JSON.stringify(request));

    let program = request.program;
    if (!program || !program.tmsId) {
        console.error("[RECORD] cancelRecording(): Missing TMS ID");
        return state;
    }

    // local  variables
    let tmsId = program.tmsId;

    // event is scheduled to record as one-shot or series
    if (state.list[tmsId]) {
        let nextState = {...state};
        console.log("[RECORD] cancelRecording(): canceling = " + JSON.stringify(nextState.list[tmsId]));
        delete nextState.list[tmsId];
        return nextState;
    }

    if (!isEpisodic(tmsId)) {
        console.error("[RECORD] cancelRecording(): " + tmsId + " is NOT set to record");
        return state;
    }

    let seriesId = getSeriesTmsId(tmsId);

    // cancel series
    if (tmsId === seriesId) {
        if (state.list[seriesId]) {
            let nextState = {...state};
            console.log("[RECORD] cancelRecording(): canceling series = " + JSON.stringify(nextState.list[tmsId]));
            delete nextState.list[tmsId];
            return nextState;
        } else {
            console.error("[RECORD] cancelRecording(): unable to find series ID");
            return state;
        }
    }

    // event is scheduled as part of series
    if (state.list[seriesId]) {
        let nextState = {...state};
        let booking = nextState.list[seriesId];

        // event is already suppressed
        let suppressionList = booking.suppressionList;
        if (suppressionList.indexOf(tmsId) >= 0) {
            console.error("[RECORD] cancelRecording(): " + tmsId + " is already in suppression list");
            return nextState;
        }

        // add event to suppression list
        nextState.list[seriesId].suppressionList.push(tmsId);
        console.log("[RECORD] cancelRecording(): adding " + tmsId + " to suppression list");

        let activeList = booking.activeList;
        let activeIndex = activeList.indexOf(tmsId);
        if (activeIndex >= 0) {
            nextState.list[seriesId].activeList.splice(activeIndex, 1);
            console.log("[RECORD] cancelRecording): removing " + tmsId + " from active list");
        }

        return nextState;
    }

    console.error("[RECORD] cancelRecording(): " + tmsId + " is NOT set to record");
    return state;
}

/**
 * Schedule recording
 *
 * @param state
 * @param request
 * @returns {*}
 */
function scheduleRecording(state, request) {
    console.log("[RECORD] scheduleRecording(): request=" + JSON.stringify(request));

    let program = request.program;
    let channel = request.channel;

    if (!program || !program.tmsId) {
        console.error("[RECORD] scheduleRecording(): Missing TMS ID");
        return state;
    }

    // local variables
    let active = request.active;
    let tmsId = program.tmsId;
    let seriesId = getSeriesTmsId(tmsId);
    let episodic = isEpisodic(tmsId);

    // event is scheduled to record as one-shot
    if (state.list[tmsId]) {

        booking = state.list[tmsId];
        let isActive = booking.active;
        let request = {
            program: {
                tmsId
            }
        };
        // cancel one-shot booking
        let nextState = cancelRecording(state, request);
        if (episodic) {
            // add series
            let booking = {
                recurring: true,
                activeList: [],
                suppressionList: [],
                options: {
                    recordEpisodes: Defaults.Recordings.RecordEpisodesIndex,
                    keepUntil: Defaults.Recordings.KeepUntilIndex,
                    keepAtMost: Defaults.Recordings.KeepAtMostIndex,
                    startExtension: Defaults.Recordings.StartExtensionIndex,
                    stopExtension: Defaults.Recordings.StopExtensionIndex
                }
            };
            // add channel information (if available)
            if (channel) {
                booking.channel = {
                    id: channel.id,
                    major: channel.major
                };
            }
            // add to active list (if active)
            if (isActive) {
                if (booking.activeList.indexOf(tmsId) < 0) {
                    booking.activeList.push(tmsId);
                }
            }

            // cancel other episodes that are scheduled to record
            let keys = Object.keys(nextState.list);
            for (let i = 0, len = keys.length; i < len; ++i) {
                let key = keys[i];
                if (isEpisodic(key) && (getSeriesTmsId(key) === seriesId)) {
                    let isActive = nextState.list[key].active;
                    nextState = cancelRecording(nextState, key);
                    if (isActive) {
                        if (booking.activeList.indexOf(key) < 0) {
                            booking.activeList.push(key);
                            console.log("[RECORD] scheduleRecording(): adding " + key + " to active list");
                        }
                    }
                }
            }

            console.log("[RECORD] scheduleRecording(): scheduling series = " + JSON.stringify(booking));
            nextState.list[seriesId] = booking;
        }

        return nextState;
    }

    // one-shot event is not scheduled
    if (!episodic) {
        let nextState = {...state};

        let booking = {
            recurring: false,
            active: active,
            options: {
                schedule: Defaults.Recordings.ScheduleIndex,
                keepUntil: Defaults.Recordings.KeepUntilIndex,
                startExtension: Defaults.Recordings.StartExtensionIndex,
                stopExtension: Defaults.Recordings.StopExtensionIndex
            }
        };
        if (channel) {
            booking.channel = {
                id: channel.id,
                major: channel.major
            };
        }
        nextState.list[tmsId] = booking;
        console.log("[RECORD] scheduleRecording(): scheduling one-shot = " + JSON.stringify(booking));

        return nextState;
    }

    // series of the episode is scheduled
    if (state.list[seriesId]) {
        let nextState = {...state};

        // remove from suppression list
        let index = nextState.list[seriesId].suppressionList.indexOf(tmsId);
        if (index >= 0) {
            nextState.list[seriesId].suppressionList.splice(index, 1);
            console.log("[RECORD] scheduleRecording(): adding " + tmsId + " to suppression list");
        }

        if (active && nextState.list[seriesId].activeList.indexOf(tmsId) < 0) {
            nextState.list[seriesId].activeList.push(tmsId);
            console.log("[RECORD] scheduleRecording(): adding " + tmsId + " to active list");
        }

        return nextState;
    }

    // event is not scheduled to record
    let nextState = {...state};

    let booking = {
        recurring: false,
        active: active,
        options: {
            schedule: Defaults.Recordings.ScheduleIndex,
            keepUntil: Defaults.Recordings.KeepUntilIndex,
            startExtension: Defaults.Recordings.StartExtensionIndex,
            stopExtension: Defaults.Recordings.StopExtensionIndex
        }
    };
    if (channel) {
        booking.channel = {
            id: channel.id,
            major: channel.major
        };
    }
    nextState.list[tmsId] = booking;
    console.log("[RECORD] scheduleRecording(): scheduling one-shot = " + JSON.stringify(booking));

    return nextState;
}