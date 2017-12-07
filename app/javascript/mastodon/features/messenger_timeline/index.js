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

  _subscribe (dispatch, id) {
    this.disconnect = dispatch(connectMessengerStream(id));
  }

  _unsubscribe () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  componentDidMount () {
    const { params, dispatch } = this.props;
    const { accountId } = this.props.params;

    dispatch(refreshMessengerTimeline(accountId));
    this._subscribe(dispatch, accountId);
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId) {
      this.props.dispatch(refreshMessengerTimeline(nextProps.params.accountId));
      this._unsubscribe();
      this._subscribe(this.props.dispatch, nextProps.params.accountId);
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
    const { accountId } = this.props.params;

    dispatch(expandMessengerTimeline(accountId));
  }

  render () {
    const { intl, hasUnread } = this.props;
    const { accountId } = this.props.params;

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
          timelineId={`messenger:${accountId}`}
          loadMore={this.handleLoadMore}
          scrollKey='messenger_timeline'
          emptyMessage={(<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here.' />)}
        />
      </Column>
    );
  }

};
