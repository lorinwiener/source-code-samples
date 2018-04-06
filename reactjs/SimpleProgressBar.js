import React, { Component, PropTypes } from 'react';

class SimpleProgressBar extends Component
{
    constructor(props)
    {
        super(props);
    }

    render()
    {
        return (
            <div className="progress-bar-wrap simple">
                <div className="progress-bar">
                    <div className="percentage" style={{"width": this.props.percentage+"%"}}></div>
                </div>
            </div>
        )

    }
}

SimpleProgressBar.propTypes = {

};


export default SimpleProgressBar;