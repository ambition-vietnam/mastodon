import { connect } from 'react-redux';
import PriceTagDropdown from '../components/price_tag_dropdown';
import { insertTagCompose } from '../../../actions/compose';
import { openModal, closeModal } from '../../../actions/modal';
import { isUserTouching } from '../../../is_mobile';

const mapStateToProps = state => ({
  isModalOpen: state.get('modal').modalType === 'ACTIONS',
  valud: state.getIn(['compose', 'price']),
});

const mapDispatchToProps = dispatch => ({
  onChange (value) {
    dispatch(insertTagCompose(`#${value}`));
  },
  isUserTouching,
  onModalOpen: props => dispatch(openModal('ACTIONS', props)),
  onModalClose: () => dispatch(closeModal()),
});

export default connect(mapStateToProps, mapDispatchToProps)(PriceTagDropdown);
