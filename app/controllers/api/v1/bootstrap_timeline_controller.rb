# frozen_string_literal: true

class Api::V1::BootstrapTimelineController < Api::BaseController
  respond_to :json

  def create
    @user = User.joins(:account)
      .where(
        last_sign_in_at: nil,
        accounts: {
          id: params[:id],
          following_count: 0
        }
      )
      .first
    if @user == nil
      render_empty
    else
      BootstrapTimelineWorker.perform_async(params[:id])
      render json: {result: 'ok'}
    end
  end
end
