require 'rails_helper'

RSpec.describe OutgoingWebhook, type: :model do
  describe 'validations' do
    it 'is invalid without name, url, trigger_word, account_id' do
      webhook = Fabricate.build(:outgoing_webhook, name: nil, url: nil, trigger_word: nil, account_id: nil, token: nil)
      webhook.valid?
      expect(webhook).to model_have_error_on_field(:name)
      expect(webhook).to model_have_error_on_field(:url)
      expect(webhook).to model_have_error_on_field(:trigger_word)
      expect(webhook).to model_have_error_on_field(:account_id)
      expect(webhook).to_not model_have_error_on_field(:token)
    end
  end

  describe 'initialize' do
    it 'generate token in initialize' do
      webhook = Fabricate.build(:outgoing_webhook)
      expect(webhook).to be_valid
      expect(webhook.token).to_not be_nil
    end
  end

  describe 'generate_token' do
    it 'generate successfully' do
      webhook = Fabricate.build(:outgoing_webhook)
      old_token = webhook.token
      webhook.generate_token
      expect(webhook.token).to_not eql old_token
    end
  end
end
