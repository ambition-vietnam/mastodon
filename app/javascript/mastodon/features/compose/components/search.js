import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Overlay from 'react-overlays/lib/Overlay';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' },
});

class SearchPopout extends React.PureComponent {

  static propTypes = {
    style: PropTypes.object,
  };

  render () {
    const { style } = this.props;

    return (
      <div style={{ ...style, position: 'absolute', width: 285 }}>
        <Motion defaultStyle={{ opacity: 0, scaleX: 0.85, scaleY: 0.75 }} style={{ opacity: spring(1, { damping: 35, stiffness: 400 }), scaleX: spring(1, { damping: 35, stiffness: 400 }), scaleY: spring(1, { damping: 35, stiffness: 400 }) }}>
          {({ opacity, scaleX, scaleY }) => (
            <div className='search-popout' style={{ opacity: opacity, transform: `scale(${scaleX}, ${scaleY})` }}>
              <h4><FormattedMessage id='search_popout.search_format' defaultMessage='Advanced search format' /></h4>

              <ul>
<<<<<<< HEAD
                <li><em>#district1</em><span> <FormattedMessage id='search_popout.tips.district' defaultMessage='and any district' /></span></li>
                <li><em>#500usd</em><span> (≦500usd)</span></li>
                <li><em>#700usd</em><span> (501≦700)</span></li>
                <li><em>#900usd</em><span> (701≦900)</span></li>
                <li><em>#1100usd</em><span> (901≦1100)</span></li>
                <li><em>#1500usd</em><span> (1101≦1500)</span></li>
                <li><em>#2000usd</em><span> (1501≦2000)</span></li>
                <li><em>#30sqm</em><span> (≦30sqm)</span></li>
                <li><em>#50sqm</em><span> (31≦50)</span></li>
                <li><em>#70sqm</em><span> (51≦70)</span></li>
                <li><em>#100sqm</em><span> (71≦100)</span></li>
                <li><em>#140sqm</em><span> (101≦140)</span></li>
                <li><em>#180sqm</em><span> (141≦180)</span></li>
              </ul>

              <FormattedMessage id='search_popout.tips.text' defaultMessage='Simple text returns matching display names, usernames and hashtags' />
            </div>
          )}
        </Motion>
      </div>
    );
  }

}

@injectIntl
export default class Search extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    submitted: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onShow: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    expanded: false,
  };

  handleChange = (e) => {
    this.props.onChange(e.target.value);
  }

  handleClear = (e) => {
    e.preventDefault();

    if (this.props.value.length > 0 || this.props.submitted) {
      this.props.onClear();
    }
  }

  handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      this.props.onSubmit();
    } else if (e.key === 'Escape') {
      document.querySelector('.ui').parentElement.focus();
    }
  }

  noop () {

  }

  handleFocus = () => {
    this.setState({ expanded: true });
    this.props.onShow();
  }

  handleBlur = () => {
    this.setState({ expanded: false });
  }

  render () {
    const { intl, value, submitted } = this.props;
    const { expanded } = this.state;
    const hasValue = value.length > 0 || submitted;

    return (
      <div className='search'>
        <label>
          <span style={{ display: 'none' }}>{intl.formatMessage(messages.placeholder)}</span>
          <input
            className='search__input'
            type='text'
            placeholder={intl.formatMessage(messages.placeholder)}
            value={value}
            onChange={this.handleChange}
            onKeyUp={this.handleKeyDown}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
          />
        </label>

        <div role='button' tabIndex='0' className='search__icon' onClick={this.handleClear}>
          <i className={`fa fa-search ${hasValue ? '' : 'active'}`} />
          <i aria-label={intl.formatMessage(messages.placeholder)} className={`fa fa-times-circle ${hasValue ? 'active' : ''}`} />
        </div>

        <Overlay show={expanded && !hasValue} placement='bottom' target={this}>
          <SearchPopout />
        </Overlay>
      </div>
    );
  }

}
