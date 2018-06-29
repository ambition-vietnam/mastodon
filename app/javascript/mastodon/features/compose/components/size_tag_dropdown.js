import React from 'react';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';
import IconButton from '../../../components/icon_button';
import Overlay from 'react-overlays/lib/Overlay';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import detectPassiveEvents from 'detect-passive-events';
import classNames from 'classnames';

const listenerOptions = detectPassiveEvents.hasSupport ? { passive: true } : false;

class SizeTagDropdownMenu extends React.PureComponent {
  static propTypes = {
    style: PropTypes.object,
    items: PropTypes.array.isRequired,
    onClose: PropTypes.func.isRequired,
    onChange: PropTypes.func.isRequired,
  };

  handleDocumentClick = e => {
    if (this.node && !this.node.contains(e.target)) {
      this.props.onClose();
    }
  }

  handleClick = e => {
    if (e.key === 'Escape') {
      this.props.onClose();
    } else if (!e.key || e.key === 'Enter') {
      const value = e.currentTarget.getAttribute('data-index');
      e.preventDefault();

      this.props.onClose();
      this.props.onChange(value);
    }
  }

  componentDidMount () {
    document.addEventListener('click', this.handleDocumentClick, false);
    document.addEventListener('touchend', this.handleDocumentClick, listenerOptions);
  }

  componentWillUnmount () {
    document.removeEventListener('click', this.handleDocumentClick, false);
    document.removeEventListener('touchend', this.handleDocumentClick, listenerOptions);
  }

  setRef = c => {
    this.node = c;
  }

  render () {
    const { style, items } = this.props;

    return (
      <Motion defaultStyle={{ opacity: 0,  scaleX: 0.85, scaleY: 0.75 }} style={{ opacity: spring(1, { damping: 35, stiffness: 400 }), scaleX: spring(1, { damping: 35, stiffness: 400 }), scaleY: spring(1, { damping: 35, stiffness: 400 }) }}>
        {({ opacity, scaleX, scaleY }) => (
          <div className='size-tag-dropdown__dropdown' style={{ ...style, opacity: opacity, transform: `scale(${scaleX}, ${scaleY})` }} ref={this.setRef}>
            {items.map(item => (
              <div role='button' tabIndex='0' key={item.value} data-index={item.value} onKeyDown={this.handleClick} onClick={this.handleClick} className={classNames('size-tag-dropdown__option')}>
                <div className='size-tag-dropdown__option__content'>
                  <strong>{item.value}</strong>
                </div>
              </div>
            ))}
          </div>
        )}
      </Motion>
    );
  }
}

@injectIntl
export default class SizeTagDropdown extends React.PureComponent {
  static propTypes = {
  isUserTouching: PropTypes.func,
    isModalOpen: PropTypes.bool.isRequired,
    onModalOpen: PropTypes.func,
    onModalClose: PropTypes.func,
    value: PropTypes.string,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    open: false,
  };

  handleToggle = () => {
    if (this.props.isUserTouching()) {
      if (this.state.open) {
        this.props.onModalClose();
      } else {
        this.props.onModalOpen({
          actions: this.options.map(option => ({ ...option, active: option.value === this.props.value })),
          onClick: this.handleModalActionClick,
        });
      }
    } else {
      this.setState({ open: !this.state.open });
    }
  }

  handleModalActionClick = (e) => {
    e.preventDefault();

    const { value } = this.options[e.currentTarget.getAttribute('data-index')];

    this.props.onModalClose();
    this.props.onChange(value);
  }

  handleKeyDown = e => {
    switch(e.key) {
      case 'Enter':
        this.handleToggle();
        break;
      case 'Escape':
        this.handleClose();
        break;
    }
  }

  handleClose = () => {
    this.setState({ open: false });
  }

  handleChange = value => {
    this.props.onChange(value);
  }

  componentWillMount () {
    const { intl: { formatMessage } } = this.props;

    this.options = [
      { value: '100sqm' },
      { value: '150sqm' },
      { value: '200sqm' },
      { value: '250sqm' },
    ];
  }

  render () {
    const { value, intl } = this.props;
    const { open } = this.state;

    return (
      <div className={classNames('size-tag-dropdown', { active: open })} onKeyDown={this.handleKeyDown}>
        <div className={classNames('size-tag-dropdown__value')}>
          <IconButton
            className='size-tag-dropdown__value-icon'
            icon='unlock-alt'
            title='ChooseSize'
            size={18}
            expanded={open}
            active={open}
            inverted
            onClick={this.handleToggle}
            style={{ height: null, lineHeight: '27px' }}
          />
        </div>

        <Overlay show={open} placement='bottom' target={this}>
          <SizeTagDropdownMenu
            items={this.options}
            onClose={this.handleClose}
            onChange={this.handleChange}
          />
        </Overlay>
      </div>
    );
  }
}
