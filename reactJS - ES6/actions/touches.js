/**
 * Copyright 2016 AT&T, Inc.
 *
 * all bugs added by ykuchinskiy@att.com || kuchinskiy@gmail.com
 *
 * @flow
 */

'use strict';

import type {Action, TouchEvent, TapClickSwipeOnTouchEvent, DragOnTouchEvent} from '../actions/types';
import * as CONST from '../constants/constants';

export function toggleTouchView(): Action {
    return {
        type: CONST.TOGGLE_TOUCH_VIEW,
    }
}

export function getTouch(events: Array<TouchEvent>): Action {
    return {
        type: CONST.TOUCH,
        events: events,
    }
}

export function getTouchOnTouch(event: TouchEvent): Action {
    return {
        type: CONST.TOUCH,
        event: event
    }
}

export function getTapOnTouch(event: TapClickSwipeOnTouchEvent): Action {
    return {
        type: CONST.TAP,
        event: event,
        meta: {sound: 'tap'},
    }
}

export function getClickOnTouch(event: TapClickSwipeOnTouchEvent): Action {
    return {
        type: CONST.CLICK,
        event: event,
        meta: {sound: 'pop'},
    }
}

export function getDrag(event: DragOnTouchEvent): Action {
    return {
        type: CONST.DRAG,
        event: event,
    }
}
