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

const mapStateToProps = (state, props) => ({
  hasUnread: state.getIn(['timelines', `messenger:${props.params.accountId}`, 'unread']) > 0,
  streamingAPIBaseURL: state.getIn([`messenger:${props.params.accountId}`, 'streaming_api_base_url']),
  accountId: Number(state.getIn(['meta', 'me'])),
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
    accountId: PropTypes.number.isRequired,
  };

  handlePin = () => {}

  handleMove = () => {}

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  _subscribe (dispatch, accountId, mentionedId) {
    this.disconnect = dispatch(connectMessengerStream(accountId, mentionedId));
  }

  _unsubscribe () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  componentDidMount () {
    const { params, dispatch, accountId } = this.props;
    const { mentionedId } = this.props.params;

    dispatch(refreshMessengerTimeline(mentionedId));
    this._subscribe(dispatch, accountId, mentionedId);
  }

  componentWillReceiveProps (nextProps) {
    const { params, dispatch, accountId } = this.props;
    const { mentionedId } = this.props.params;

    if (nextProps.params.mentionedId !== mentionedId) {
      dispatch(refreshMessengerTimeline(mentionedId));
      this._unsubscribe();
      this._subscribe(dispatch, accountId, mentionedId);
    }
  }

  componentWillUnmount () {
    this._unsubscribe();
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = () => {
    const { dispatch, params } = this.props;
    const { mentionedId } = this.props.params;

    dispatch(expandMessengerTimeline(mentionedId));
  }

  render () {
    const { intl, hasUnread } = this.props;
    const { mentionedId } = this.props.params;

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
          timelineId={`messenger:${mentionedId}`}
          loadMore={this.handleLoadMore}
          scrollKey='messenger_timeline'
          emptyMessage={(<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here.' />)}
        />
      </Column>
    );
  }

};
