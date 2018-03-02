# == Schema Information
#
# Table name: outgoing_webhooks
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  url          :string           default(""), not null
#  trigger_word :string           default(""), not null
#  token        :string           default(""), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class OutgoingWebhook < ApplicationRecord
  def generate_token
    self.token = SecureRandom.urlsafe_base64
    self
  end
end
