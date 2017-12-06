import { connect } from 'react-redux';
import { makeGetMessengerAccount } from '../selectors';
import { openModal } from '../actions/modal';
import MessengerAccount from '../components/messenger_account';
import {
  followAccount,
  unfollowAccount,
} from '../actions/accounts';

const makeMapStateToProps = () => {
  const getAccount = makeGetMessengerAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
    me: state.getIn(['meta', 'me']),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({
  onFollow (account) {
    if (account.getIn(['relationship', 'following'])) {
      dispatch(unfollowAccount(account.get('id')));
    } else {
      dispatch(followAccount(account.get('id')));
    }
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(MessengerAccount);
