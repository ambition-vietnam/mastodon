# frozen_string_literal: true

require 'sidekiq-bulk'

class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    raise Mastodon::RaceConditionError if status.visibility.nil?

    deliver_to_self(status) if status.account.local?

    if status.direct_visibility?
      deliver_to_mentioned_followers(status)
    else
      deliver_to_followers(status)
      deliver_to_lists(status)
    end

    remove_from_public(status) if status.edited && !status.public_visibility?
    return if status.account.silenced? || !status.public_visibility? || status.reblog?

    render_anonymous_payload(status)
    deliver_to_hashtags(status)

    return if status.reply? && status.in_reply_to_account_id != status.account_id

    deliver_to_public(status) unless status.edited?
  end

  private

  def deliver_to_self(status)
    Rails.logger.debug "Delivering status #{status.id} to author"
    FeedManager.instance.push_to_home(status.account, status)
  end

  def deliver_to_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to followers"

    status.account.followers.where(domain: nil).joins(:user).where('users.current_sign_in_at > ?', 14.days.ago).select(:id).reorder(nil).find_in_batches do |followers|
      if status.edited
        MergeWorker.push_bulk(followers) do |follower|
          [status.account_id, follower.id]
        end
      else
        FeedInsertWorker.push_bulk(followers) do |follower|
          [status.id, follower.id, :home]
        end
      end
    end
  end

  def deliver_to_lists(status)
    Rails.logger.debug "Delivering status #{status.id} to lists"

    status.account.lists.joins(account: :user).where('users.current_sign_in_at > ?', 14.days.ago).select(:id).reorder(nil).find_in_batches do |lists|
      FeedInsertWorker.push_bulk(lists) do |list|
        [status.id, list.id, :list]
      end
    end
  end

  def deliver_to_mentioned_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to mentioned followers"

    mentioned_accounts = []
    status.mentions.includes(:account).each do |mention|
      mentioned_account = mention.account
      next if !mentioned_account.local? || !mentioned_account.following?(status.account) || FeedManager.instance.filter?(:home, status, mention.account_id)
      mentioned_accounts[mentioned_account.id] = mentioned_account.id
      if status.edited
        MergeWorker.perform_async(status.account_id, mentioned_account.id)
      else
        FeedManager.instance.push_to_home(mentioned_account, status)
      end
    end

    account = Account.find(status.account_id)
    account.followers.local.find_each do |follower|
      next unless mentioned_accounts[follower.id].blank?
      FeedManager.instance.unpush_from_home(follower, status)
    end

    UnfavouriteOtherThanMentionedWorker.perform_async(status.id)
  end

  def render_anonymous_payload(status)
    @payload = InlineRenderer.render(status, nil, :status)
    @payload = Oj.dump(event: :update, payload: @payload, type: nil)
  end

  def deliver_to_hashtags(status)
    Rails.logger.debug "Delivering status #{status.id} to hashtags"

    status.tags.pluck(:name).each do |hashtag|
      Redis.current.publish("timeline:hashtag:#{hashtag}", @payload)
      Redis.current.publish("timeline:hashtag:#{hashtag}:local", @payload) if status.local?
    end
  end

  def deliver_to_public(status)
    Rails.logger.debug "Delivering status #{status.id} to public timeline"

    Redis.current.publish('timeline:public', @payload)
    Redis.current.publish('timeline:public:local', @payload) if status.local?
  end

  def remove_from_public(status)
    Rails.logger.debug "Removing status #{status.id} from public timeline"

    Redis.current.publish('timeline:public', Oj.dump(event: :delete, payload: status.id.to_s, type: :edit))
    Redis.current.publish('timeline:public:local', Oj.dump(event: :delete, payload: status.id.to_s, type: :edit)) if status.local?
  end
end
