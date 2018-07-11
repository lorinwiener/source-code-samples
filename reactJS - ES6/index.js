'use strict';

import React from 'react';
import ReactDOM from 'react-dom';
import {persistStore, storages} from 'redux-persist';

import Root           from './containers/Root';
import configureStore from '../store/ConfigureStore';

import * as charRoom from '../store/ChatRoom';

// Load css
require('./styles/index.less');

function getStore() {

    const store = configureStore();

    const config = {
        storage: storages.localStorage,
        whitelist: ['profile'],// this is only one reducer that I would like to persist
    };

    persistStore(store, config, () => {
            console.info("State after rehydration: ");
            console.dir(store.getState());
            charRoom.init(store, "CLIENT");
        }
    );

    return store;

}

const store = getStore();

const rootElement = document.getElementById('root');

console.log("window.innerWidth: " + window.innerWidth);
console.log("window.innerHeight: " + window.innerHeight);

console.log("window.outerWidth: " + window.outerWidth);
console.log("window.outerHeight: " + window.outerHeight);

console.log("window.devicePixelRatio: " + window.devicePixelRatio);


console.dir(window.screen);
console.dir(window.navigator);
console.dir(window.location);


ReactDOM.render(<Root store={store}/>, rootElement);
