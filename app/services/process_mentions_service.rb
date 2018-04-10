# frozen_string_literal: true

class ProcessMentionsService < BaseService
  include StreamEntryRenderer

  # Scan status for mentions and fetch remote mentioned users, create
  # local mention pointers, send Salmon notifications to mentioned
  # remote users
  # @param [Status] status
  def call(status)
    return unless status.local?

    new_mentioned_accounts = {}
    old_mentions = get_mentions(status)
    status.text = status.text.gsub(Account::MENTION_RE) do |match|
      username, domain  = $1.split('@')
      mentioned_account = Account.find_remote(username, domain)

      if mention_undeliverable?(status, mentioned_account)
        begin
          mentioned_account = resolve_account_service.call($1)
        rescue Goldfinger::Error, HTTP::Error
          mentioned_account = nil
        end
      end

      mentioned_account ||= Account.find_remote(username, domain)

      next match if mention_undeliverable?(status, mentioned_account)

      new_mentioned_accounts[mentioned_account.id] = true
      mentioned_account.mentions.where(status: status).first_or_create(status: status)
      "@#{mentioned_account.acct}"
    end

    status.save!

    status.mentions.includes(:account).each do |mention|
      create_notification(status, mention)
    end

    remove_old_mentions(status, new_mentioned_accounts, old_mentions)
  end

  private

  def mention_undeliverable?(status, mentioned_account)
    mentioned_account.nil? || (!mentioned_account.local? && mentioned_account.ostatus? && status.stream_entry.hidden?)
  end

  def create_notification(status, mention)
    mentioned_account = mention.account

    if mentioned_account.local?
      NotifyService.new.call(mentioned_account, mention)
    elsif mentioned_account.ostatus? && !status.stream_entry.hidden?
      NotificationWorker.perform_async(stream_entry_to_xml(status.stream_entry), status.account_id, mentioned_account.id)
    elsif mentioned_account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(mention.status), mention.status.account_id, mentioned_account.inbox_url)
    end
  end

  def get_mentions(status)
    Mention.where(status_id: status.id)
  end

  def remove_old_mentions(status, new_mentioned_accounts, old_mentions)
    payload = Oj.dump(event: :delete, payload: status.id.to_s)
    old_mentions.each do |mention|
      next if new_mentioned_accounts[mention.account.id].present?
      Redis.current.publish("timeline:#{mention.account.id}", payload)
      mention.destroy
    end
  end

  def build_json(status)
    Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: ActivityPub::ActivitySerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(status.account))
  end

  def resolve_account_service
    ResolveAccountService.new
  end
end
