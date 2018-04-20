# frozen_string_literal: true

class Api::V1::SuggestedAccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  SUGGESTED_ACCOUNTS_LIMIT = 20

  def index
    limit = limit_param(SUGGESTED_ACCOUNTS_LIMIT)
    page = params[:page].to_i
    seed = params[:seed] ? params[:seed].to_i : Random.new_seed

    query = suggested_accounts(current_user.account)
      .shuffle(seed)
      .per(limit)
      .page(params[:page])

    @accounts = query.all


    next_path = api_v1_suggested_accounts_url(seed: seed, page: page + 1) if page < 50 && @accounts.present?
    prev_path = api_v1_suggested_accounts_url(seed: seed, page: page - 1) if page.positive?
    set_pagination_headers(next_path, prev_path)

    media_attachments_of = Pawoo::LoadAccountMediaAttachmentsService.new.call(@accounts, 3)
    render json: @accounts, each_serializer: REST::SuggestedAccountSerializer, media_attachments_of: media_attachments_of

  end

  private

  def suggested_accounts(account)
    following = account.following.ids
    muted_and_blocked = account.excluded_from_timeline_account_ids

    SuggestedAccountQuery.new
      .exclude_ids([account.id] + following + muted_and_blocked)
      # .with_pixiv_follows(oauth_authentication, limit: 6)
      # .with_tradic(account, limit: 6)
  end
end
