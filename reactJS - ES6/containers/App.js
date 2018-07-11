import React, {Component, PropTypes} from 'react';
import {connect} from 'react-redux';

import Application from '../components/Application';

class MotionFrameworkWeb extends Component {

    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div className="tv-app">
                <Application />
            </div>
        );
    }
}

MotionFrameworkWeb.propTypes = {

};

const select = state => state;

// Wrap the component to inject dispatch and state into it
export default connect(select)(MotionFrameworkWeb);
