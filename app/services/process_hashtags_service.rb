# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags = Extractor.extract_hashtags(status.text) if status.local?
    @fee = nil
    @type = nil
    @area = nil

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

    get_recommend_statuses(target_status.account.account_type).each do |status|
      text = "@#{Rails.configuration.x.admin_account} Recommend for #{target_status.uri}\n\n"
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

  def get_recommend_statuses(account_type)
    args = { account_type: account_type == 'owner' ? 2 : 1 }

    if @fee
      range = @fee < 1000 ? 100 : 200
      fee_tags = Tag.find_by_fee_range(@fee, range).map(&:id)
      join_fee_tags = "INNER JOIN statuses_tags as fee_tags ON statuses.id = fee_tags.status_id AND fee_tags.tag_id in (:fee_tags)"
      args[:fee_tags] = fee_tags
    end

    if @type
      type_tags = Tag.where("name like '#{@type}%'").map(&:id)
      join_type_tags = "INNER JOIN statuses_tags as type_tags ON statuses.id = type_tags.status_id AND type_tags.tag_id in (:type_tags)"
      args[:type_tags] = type_tags
    end

    if @area
      area_tags = Tag.where("name like '#{@area}%'").map(&:id)
      join_area_tags = "INNER JOIN statuses_tags as area_tags ON statuses.id = area_tags.status_id AND area_tags.tag_id in (:area_tags)"
      args[:area_tags] = area_tags
    end

    sql = <<-SQL
      SELECT statuses.id FROM statuses 
        INNER JOIN accounts ON statuses.account_id = accounts.id AND account_type = :account_type
        #{join_fee_tags}
        #{join_type_tags}
        #{join_area_tags}
    SQL

    Status.find_by_sql([sql, args])
  end

  def get_recommend_parameters(tag)
    get_fee_tag(tag)
    get_type_tag(tag)
    get_area_tag(tag)
  end

  def get_fee_tag(tag)
    @fee = tag.slice(/\d+/).to_i if tag.end_with?('usd')
  end

  def get_type_tag(tag)
    Rails.configuration.x.bedtypes.split(',').each do |type|
      @type = type if tag.start_with?(type)
    end
  end

  def get_area_tag(tag)
    Rails.configuration.x.districts.split(',').each do |area|
      @area = area if tag.start_with?(area)
    end
  end
end
