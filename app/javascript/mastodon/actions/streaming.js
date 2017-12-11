import createStream from '../stream';
import {
  updateTimeline,
  deleteFromTimelines,
  refreshHomeTimeline,
  refreshMessengerTimeline,
  connectTimeline,
  disconnectTimeline,
} from './timelines';
import { updateNotifications, refreshNotifications } from './notifications';
import { getLocale } from '../locales';

const { messages } = getLocale();

export function connectTimelineStream (timelineId, path, pollingRefresh = null, shouldCheckUpdate = false) {
  return (dispatch, getState) => {
    const streamingAPIBaseURL = getState().getIn(['meta', 'streaming_api_base_url']);
    const accessToken = getState().getIn(['meta', 'access_token']);
    const locale = getState().getIn(['meta', 'locale']);
    let polling = null;

    const setupPolling = () => {
      polling = setInterval(() => {
        pollingRefresh(dispatch);
      }, 20000);
    };

    const clearPolling = () => {
      if (polling) {
        clearInterval(polling);
        polling = null;
      }
    };

    const subscription = createStream(streamingAPIBaseURL, accessToken, path, {

      connected () {
        if (pollingRefresh) {
          clearPolling();
        }
        dispatch(connectTimeline(timelineId));
      },

      disconnected () {
        if (pollingRefresh) {
          setupPolling();
        }
        dispatch(disconnectTimeline(timelineId));
      },

      received (data) {
        switch(data.event) {
        case 'update':
          if (shouldCheckUpdate) {
            dispatchMessengerTimeline(dispatch, JSON.parse(data.payload), timelineId);
          } else {
            dispatch(updateTimeline(timelineId, JSON.parse(data.payload)));
          }
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        case 'notification':
          dispatch(updateNotifications(JSON.parse(data.payload), messages, locale));
          break;
        }
      },

      reconnected () {
        if (pollingRefresh) {
          clearPolling();
          pollingRefresh(dispatch);
        }
        dispatch(connectTimeline(timelineId));
      },

    });

    const disconnect = () => {
      if (subscription) {
        subscription.close();
      }
      clearPolling();
    };

    return disconnect;
  };
}

function refreshHomeTimelineAndNotification (dispatch) {
  dispatch(refreshHomeTimeline());
  dispatch(refreshNotifications());
}

function dispatchMessengerTimeline (dispatch, status, timelineId) {
  const splitedTimelineId = timelineId.split(':');
  if (splitedTimelineId.length !== 3 || splitedTimelineId[0] !== 'messenger') {
    return false;
  }

  switch(status.account.id) {
    case splitedTimelineId[1]:
    case splitedTimelineId[2]:
      dispatch(refreshMessengerTimeline(splitedTimelineId[2]));
      break;
  }
}

export const connectUserStream = () => connectTimelineStream('home', 'user', refreshHomeTimelineAndNotification);
export const connectCommunityStream = () => connectTimelineStream('community', 'public:local');
export const connectMediaStream = () => connectTimelineStream('community', 'public:local');
export const connectPublicStream = () => connectTimelineStream('public', 'public');
export const connectHashtagStream = (tag) => connectTimelineStream(`hashtag:${tag}`, `hashtag&tag=${tag}`);
export const connectMessengerStream = (accountId, mentionedId) => connectTimelineStream(`messenger:${accountId}:${mentionedId}`, `messenger&accountId=${accountId}&mentionedId=${mentionedId}`, null, true);
