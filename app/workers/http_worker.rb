#frozen_string_literal: true

class HttpWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 5

  def perform(url, method = 'get', params = {}, headers = {})
    HttpService.new.call(url, method, params, headers)
  end
end
