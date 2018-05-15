# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags = Extractor.extract_hashtags(status.text) if status.local?

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |tag|
      get_recommend_parameters(tag)
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end

    recommend(status)
    status.update(sensitive: true) if tags.include?('nsfw')
  end

  private

  def recommend(target_status)
    return if !@fee && !@type
    return if target_status.account.account_type == 'admin'
    return if target_status.visibility != 'public'

    headers = {
      'Authorization' => "Bearer #{Rails.configuration.x.recommend_token}",
      'Content-Type' => 'application/json'
    }
    statuses = Status.recommend(target_status.account.account_type, @fee, @type, @area)
    statuses.each do |status|
      text = "@tkera Recommend for #{target_status.uri}\n\n"
      text += "Fee " if @fee
      text += "Bedtype " if @type
      text += "Area " if @area
      text += "mathes.\n"
      text += "https://#{Rails.configuration.x.local_domain}/web/statuses/#{status.id}"
      params = {
        status: text,
        visibility: 'direct'
      }.to_json

      HttpWorker.perform_async("http://#{Rails.configuration.x.local_domain}/api/v1/statuses", 'post', params, headers)
    end
  end

  def get_recommend_parameters(tag)
    @fee = tag.slice(/\d+/).to_i if tag.end_with?('usd')
    get_type_tag(tag)
    get_area_tag(tag)
  end

  def get_type_tag(tag)
    @type = nil
    Rails.configuration.x.bedtypes.split(',').each do |type|
      @type = type if tag.start_with?(type)
    end
  end

  def get_area_tag(tag)
    @area = nil
    Rails.configuration.x.districts.split(',').each do |area|
      @area = area if tag.start_with?(area)
    end
  end
end
