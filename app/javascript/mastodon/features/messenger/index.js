import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import {
  fetchMessengerAccounts,
  expandMessengerAccounts,
} from '../../actions/accounts';
import { ScrollContainer } from 'react-router-scroll';
import MessengerAccountContainer from '../../containers/messenger_account_container';
import Column from '../ui/components/column';
import ColumnHeader from '../../components/column_header';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import LoadMore from '../../components/load_more'
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'column.messenger', defaultMessage: 'Messenger' },
});

const mapStateToProps = (state) => ({
  accountIds: state.getIn(['user_lists', 'messenger_accounts', 'items']),
  hasMore: !!state.getIn(['user_lists', 'messenger_accounts', 'next']),
});

@connect(mapStateToProps)
@injectIntl
export default class Messenger extends ImmutablePureComponent {

  static PropTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    columnId: PropTypes.string,
    hasMore: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  componentWillMount() {
    this.props.dispatch(fetchMessengerAccounts());
  }

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('MESSENGER', {}));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight && this.props.hasMore) {
      this.props.dispatch(expandMessengerAccounts());
    }
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.props.dispatch(expandMessengerAccounts());
  }

  render () {
    const { accountIds, intl, columnId, multiColumn, hasMore } = this.props;
    const pinned = !!columnId;

    let loadMore = null;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    if (hasMore) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='user'
          title={intl.formatMessage(messages.heading)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          showBackButton
        />

        <ScrollContainer scrollKey={`messenger-${columnId}`}>
          <div className='scrollable' onScroll={this.handleScroll}>
            <div className='messenger'>
              {accountIds.map(id => <MessengerAccountContainer key={id} id={id} withNote={false} />)}
              {loadMore}
            </div>
          </div>
        </ScrollContainer>
      </Column>
    );
  };
};
