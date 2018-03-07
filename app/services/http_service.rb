# frozen_string_literal: true

require 'net/http'

class HttpService < BaseService
  def call(url, method = 'get', params = {})
    uri = URI(url)
    if method == 'get'
      res = Net::HTTP.get_response(uri)
    else
      res = Net::HTTP.post_form(uri, params)
    end
    res.body
  end
end
