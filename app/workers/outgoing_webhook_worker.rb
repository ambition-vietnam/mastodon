# frozen_string_literal: true

class OutgoingWebhookWorker
  include Sidekiq::Worker

  def perform(status_id)
    @status = Status.find(status_id)

    @status.account.outgoing_webhooks.each do |webhook|
      if @status.text.include? webhook.trigger_word
        HttpService.new.call(webhook.url, 'post', set_webhook_params(webhook))
      end
    end
  end

  private

  def set_webhook_params(webhook)
    params = {
      text: @status.text,
      account_id: @status.account_id,
      timestamp: @status.updated_at,
      account_name: @status.account.username,
      domain: @status.account.domain,
      token: webhook.token,
      trigger_word: webhook.trigger_word
    }
  end
end
