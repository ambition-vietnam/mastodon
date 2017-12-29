import { connect } from 'react-redux';
import { cancelEditCompose } from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';
import EditIndicator from '../components/edit_indicator';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = state => ({
    status: getStatus(state, state.getIn(['compose', 'statusId'])),
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({

  onCancel () {
    dispatch(cancelEditCompose());
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(EditIndicator);
