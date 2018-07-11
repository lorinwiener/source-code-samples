import React, {Component, PropTypes} from 'react';
import {Provider} from 'react-redux';
import MotionFrameworkWeb from './App';
import DevTools from './DevTools';

export default class Root extends Component {
    render() {
        return (
            <Provider store={this.props.store}>
                <div>
                    <MotionFrameworkWeb />
                    <DevTools />
                </div>
            </Provider>
        );
    }
}

Root.propTypes = {
    store: PropTypes.object.isRequired
};
