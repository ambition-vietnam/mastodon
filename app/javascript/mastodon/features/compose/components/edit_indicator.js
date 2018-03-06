import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from '../../../components/avatar';
import IconButton from '../../../components/icon_button';
import DisplayName from '../../../components/display_name';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { isRtl } from '../../../rtl';

const messages = defineMessages({
  cancel: { id: 'edit_indicator.cancel', defaultMessage: 'Cancel' },
});

@injectIntl
export default class EditIndicator extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    onCancel: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.onCancel();
  }

  handleAccountClick = (e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }
  }

  render () {
    const { status, intl } = this.props;

    if (!status) {
      return null;
    }

    return (
      <div className='edit-indicator'>
        <div className='edit-indicator__header'>
          <div className='edit-indicator__cancel' style={{display: status.get('in_reply_to_id') ? 'none' : 'block' }}>
            <IconButton title={intl.formatMessage(messages.cancel)} icon='times' onClick={this.handleClick} />
          </div>
          <span className='edit-indicator__content'>Edit Toot</span>
        </div>
      </div>
    );
  }
}
