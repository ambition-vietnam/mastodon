# frozen_string_literal: true

class UnfavouriteOtherThanMentionedWorker
  include Sidekiq::Worker

  def perform(status_id)
    status = Status.find(status_id)
    mentions = Mention.where(status_id: status_id)

    related_accounts = [status.account_id]
    mentions.each do |mention|
      related_accounts.push(mention.account_id)
    end

    favs = Favourite.where.not(account_id: related_accounts)
    favs.each do |fav|
      UnfavouriteService.new.call(Account.find(fav.account_id), status)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
