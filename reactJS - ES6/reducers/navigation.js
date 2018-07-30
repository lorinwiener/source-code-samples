'use strict';

import * as cont from '../constants/constants';


import {pageNavigation} from '../navigation/pageNavigation';

export const navigationState = {
    navigation: {
        col: 0,
        row: 0,
        matrix: []
    }
};


export default function navigationReducer(state = navigationState, action) {

    let matrix = [
            {"row": 0, "col": 1},
            {"row": 1, "col": 3},
            {"row": 2, "col": 1}
        ];

    switch (action.type) {
        case cont.CLICK:
        case cont.TAP:
        case cont.SWIPE:
            return pageNavigation(state, {direction: action.event.direction, initial: true}, matrix);
    }
    return state;
}