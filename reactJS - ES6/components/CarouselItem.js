'use strict';

import React, {Component, PropTypes} from 'react';
import {connect} from 'react-redux';

import MetaData from './MetaData';
import ListMeta from '../shared_components/ListMeta';
import SimpleProgressBar from '../shared_components/SimpleProgressBar';
import RecordingMessage from '../shared_components/RecordingMessage';

import {
    getMetaListFromEvent,
    getMetaListFromPerson,
    getMetaListFromFolder,
    cutToSize,
    getProgTypeFromTmsId
} from '../../../constants/Utils';

import {BookingHelper} from '../../../constants/BookingUtils';

const singleColWidth = 102;

class CarouselItem extends Component {

    constructor(props) {
        super(props);
        this.getTitle = this.getTitle.bind(this);
        this.getMetaList = this.getMetaList.bind(this);
        this.getChannelLogo = this.getChannelLogo.bind(this);
        this.getProgressBar = this.getProgressBar.bind(this);
        this.getInfo = this.getInfo.bind(this);
    }

    componentWillMount() {

        if (this.props.type === 'Person' || this.props.type === 'Folder') {
            this.state = {
                isScheduled: false,
                isRecurring: false,
                displayRecordingTip: false
            }
        } else {
            let tmsId = this.props.data.event.tmsId;
            let schedule = this.props.todos.list;
            let isScheduled = BookingHelper.isScheduledById(tmsId, schedule);
            let isRecurring = BookingHelper.isRecurringById(tmsId, schedule);
            let displayRecordingTip = !isScheduled;
            this.state = {
                isScheduled,
                isRecurring,
                displayRecordingTip
            };
        }
    }

    componentWillUpdate(nextProps, nextState) {
        if (this.props.type === 'Person' || this.props.type === 'Folder') {
            return;
        }

        if (!this.props.active && nextProps.active) {
            let tmsId = nextProps.data.event.tmsId;
            let schedule = nextProps.todos.list;
            let isScheduled = BookingHelper.isScheduledById(tmsId, schedule);
            let isRecurring = BookingHelper.isRecurringById(tmsId, schedule);
            let displayRecordingTip = false;
            this.setState({
                isScheduled,
                isRecurring,
                displayRecordingTip
            })
        }

        if (this.props.active) {
            let tmsId = this.props.data.event.tmsId;
            let schedule = this.props.todos.list;
            let isScheduled = BookingHelper.isScheduledById(tmsId, schedule);
            let isRecurring = BookingHelper.isRecurringById(tmsId, schedule);
            if (this.state.isScheduled !== isScheduled || this.state.isRecurring !== isRecurring) {
                let displayRecordingTip = true;
                this.setState({
                    isScheduled,
                    isRecurring,
                    displayRecordingTip
                });
            }
        }
    }

    getTitle(type) {
        let title = '';
        switch (type) {
            case 'Person':
                let firstName = this.props.data.celeb.firstName;
                let lastName = this.props.data.celeb.lastName;
                if (firstName && lastName) {
                    title = firstName + " " + lastName;
                }
                break;
            case 'Program':
            case 'Channel':
                title = this.props.data.event.title;
                break;
            case 'Folder':
                title = this.props.data.folder[0].title;
                break;
        }
        return title;
    }

    getMetaList(type) {
        switch (type) {
            case 'Person':
                return getMetaListFromPerson(this.props.data.celeb);
            case 'Program':
            case 'Channel':
                return getMetaListFromEvent(this.props.data.event);
            case 'Folder':
                return getMetaListFromFolder(this.props.data.folder);
        }
        return [];
    }

    getChannelLogo(type) {
        switch (type) {
            case 'Person':
            case 'Program':
            case 'Folder':
                return null;
            case 'Channel':
                return (
                    <div className="channel-overlay">
                        <div className="channel-icon">
                            <img src={this.props.data.channel.logo} />
                        </div>
                    </div>
                );
        }
    }

    getProgressBar(type) {
        switch (type) {
            case 'Person':
            case 'Program':
            case 'Folder':
                return null;
            case 'Channel':
                console.log(this.props.data);
                return (
                    <SimpleProgressBar percentage={this.props.data.schedule.videoPercentage}/>
                );
        }
    }

    getInfo(tmsId, title, infoClass, isScheduled, isRecording, isRecurring) {
        let infoActive = (this.props.active && !this.props.isCabActive);
        let metalist = this.getMetaList(this.props.type);
        if(isScheduled && !this.props.isCabActive) {
            infoClass += " recording-on";
            let type = getProgTypeFromTmsId(tmsId);
            let recordingMsg = this.state.displayRecordingTip ?
                <RecordingMessage type={type} isRecording={isRecording} isRecurring={isRecurring} /> :
                <ListMeta metalist={metalist} />;
            return (
                <div className={infoClass}>
                    <MetaData title={cutToSize(title, 25)} desp='' isScheduled={isScheduled} isRecording={isRecording} isRecurring={isRecurring} infoActive={infoActive} />
                    {recordingMsg}
                </div>
            );
        } else {
            return (
                <div className={infoClass}>
                    <MetaData title={cutToSize(title, 30)} desp='' isScheduled={isScheduled} isRecording={isRecording} isRecurring={isRecurring} infoActive={infoActive} />
                    <ListMeta metalist={metalist} />
                </div>
            );
        }
        return null;
    }

    render() {
        let posterWidth = singleColWidth * this.props.width;
        let colStyle = {
            width: posterWidth + 'px'
        };

        let itemClass = 'carousel-item';
        if (this.props.type === 'Person') {
            itemClass += ' oval';
        }
        if (this.props.active) {
            itemClass += " highlight";
            if (this.props.isCabActive) {
                itemClass += " cab-active";
            }
        }

        let listItemClass = "carousel-list-item";
        if (this.props.display) {
            listItemClass += " invisible";
        }

        let posterClass = "poster";
        if (this.props.display) {
            posterClass += " zoomOut";
        }

        let infoClass = 'info fadeOut';
        if (this.props.active && !this.props.isCabActive) {
            infoClass = 'info';
        }

        let title = this.getTitle(this.props.type);
        let channelLogo = this.getChannelLogo(this.props.type);

        let simpleProgressBar = this.getProgressBar(this.props.type);

        let tmsId = (this.props.data.event) ? this.props.data.event.tmsId : '';

        let isScheduled = BookingHelper.isScheduledById(tmsId, this.props.todos.list);
        let isRecording = BookingHelper.isRecordingById(tmsId, this.props.todos.list);
        let isRecurring = BookingHelper.isRecurringById(tmsId, this.props.todos.list);

        let info = this.getInfo(tmsId, title, infoClass, isScheduled, isRecording, isRecurring);

        return (
            <div className={listItemClass}>
                <div className={itemClass} style={colStyle}>
                    <div className={posterClass}>
                        <img src={this.props.data.poster.url}></img>
                        {channelLogo}
                        {simpleProgressBar}
                    </div>
                    {info}
                </div>
            </div>
        );
    }
}

CarouselItem.propTypes = {
    type: PropTypes.string.isRequired,
    active: PropTypes.bool.isRequired,
    index: PropTypes.number.isRequired,
    width: PropTypes.number.isRequired,
    data: PropTypes.object.isRequired,

    display: PropTypes.bool,
    isCabActive: PropTypes.bool
};

const mapStateToProps = store => {
   return {
       todos: {
           list: store.todos.list
       }
   }
};

export default connect(mapStateToProps)(CarouselItem);
