import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import {
  refreshMessengerTimeline,
  expandMessengerTimeline,
} from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
//import ColumnSettingsContainer from './containers/column_settings_container';
import { connectMessengerStream } from '../../actions/streaming';

const messages = defineMessages({
  title: { id: 'column.messenger_timeline', defaultMessage: 'Messenger timeline' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'messenger', 'unread']) > 0,
  streamingAPIBaseURL: state.getIn(['messenger', 'streaming_api_base_url']),
  accessToken: state.getIn(['meta', 'access_token']),
});

@connect(mapStateToProps)
@injectIntl
export default class MessengerTimeline extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    params: PropTypes.object.isRequired,
  };

  handlePin = () => {}

  handleMove = () => {}

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  componentDidMount () {
    const { params, dispatch } = this.props;
    dispatch(refreshMessengerTimeline(params.accountId));
    this.disconnect = dispatch(connectMessengerStream(params.accountId));
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = () => {
    const { params } = this.props;
    this.props.dispatch(expandMessengerTimeline(params.accountId));
  }

  render () {
    const { intl, hasUnread } = this.props;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='envelope'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={false}
          multiColumn={false}
          showBackButton
        />
        <StatusListContainer
          timelineId='messenger'
          loadMore={this.handleLoadMore}
          scrollKey='messenger_timeline'
          emptyMessage={(<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here.' />)}
        />
      </Column>
    );
  }

};
