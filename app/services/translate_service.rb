# frozen_string_literal: true

require 'json'
require 'google/cloud/translate'

class TranslateService < BaseService
  def call(text, target)
    return text if ENV['GOOGLE_APPLICATION_CREDENTIALS'].nil?

    credentials = File.read(ENV['GOOGLE_APPLICATION_CREDENTIALS'])
    project_id = JSON.parse(credentials)['project_id']
    translate = Google::Cloud::Translate.new project: project_id
    translation = translate.translate text, to: target
  end
end
