# frozen_string_literal: true

class Api::V1::SuggestedAccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  def index
    accounts = Account.suggested_accounts_for(current_user.account.account_type)
    media_attachments_of = LoadAccountMediaAttachmentsService.new.call(accounts, 3)

    render json: accounts, each_serializer: REST::SuggestedAccountSerializer, media_attachments_of: media_attachments_of
  end
end
