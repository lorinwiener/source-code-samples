/**
 * Copyright 2016 AT&T, Inc.
 *
 * all bugs added by ykuchinskiy@att.com || kuchinskiy@gmail.com
 *
 * @flow
 */

'use strict';

import {combineReducers} from 'redux';

import touchesReducer from './touches';
import eventsReducer from './events';
import profileReducer from './profile';
import todosReducer from './todos';
import navigationReducer from './navigation';

import type {Action} from '../actions/types';

const combinedReducer = combineReducers({
    events: eventsReducer,
    touches: touchesReducer,
    profile: profileReducer,
    todos: todosReducer,
    navigation: navigationReducer
});


const rootReducer = (state: any, action: Action) => {
    return combinedReducer(state, action);
};

export default rootReducer;
