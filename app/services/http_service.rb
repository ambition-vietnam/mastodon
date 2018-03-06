# frozen_string_literal: true

require 'net/http'

class HttpService < BaseService
  def post(url, params)
    uri = URI(url)
    res = Net::HTTP.post_form(uri, params)
    res.body
  end
end
