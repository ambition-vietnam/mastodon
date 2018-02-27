import { connect }   from 'react-redux';
import TrendTags from '../components/trend_tags';
import { refreshTrendTags } from '../../../actions/trend_tags';
import { insertTagCompose } from '../../../actions/compose';

const mapStateToProps = state => {
  return {
    tags: state.getIn(['trend_tags', 'tags']),
  };
};

const mapDispatchToProps = dispatch => ({
  refreshTrendTags () {
    dispatch(refreshTrendTags());
  },
  insertTagCompose (tag) {
    dispatch(insertTagCompose(tag));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(TrendTags);
