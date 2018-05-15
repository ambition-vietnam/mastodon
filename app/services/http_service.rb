# frozen_string_literal: true

require 'net/http'

class HttpService < BaseService
  def call(url, method = 'get', params = {}, headers = {})
    if method == 'get'
      uri = URI(url)
      res = Net::HTTP.get_response(uri)
    else
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = false

      req = Net::HTTP::Post.new(uri.request_uri)
      headers.each_key do |key|
        req[key] = headers[key]
      end
      req.body = params
      res = https.request(req)
    end
    res.body
  end
end
