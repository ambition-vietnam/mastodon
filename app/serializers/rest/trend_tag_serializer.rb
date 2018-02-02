# frozen_string_literal: true

class REST::TrendTagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name, :url, :type, :description

  def url
    tag_url(object.name)
  end

  def type
    object.tag_type
  end
end
