# == Schema Information
#
# Table name: outgoing_webhooks
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  url          :string           default(""), not null
#  trigger_word :string           default(""), not null
#  token        :string           default(""), not null
#  account_id   :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class OutgoingWebhook < ApplicationRecord
  def initialize(params = {})
    super(params)
    generate_token
  end

  def generate_token
    write_attribute(:token, SecureRandom.urlsafe_base64)
  end
end
