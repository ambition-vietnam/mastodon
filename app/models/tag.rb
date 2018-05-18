# frozen_string_literal: true
# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ApplicationRecord
  has_and_belongs_to_many :statuses

  HASHTAG_NAME_RE = '[[:word:]_]*[[:alpha:]_·][[:word:]_]*'
  HASHTAG_RE = /(?:^|[^\/\)\w])#(#{HASHTAG_NAME_RE})/i

  validates :name, presence: true, uniqueness: true, format: { with: /\A#{HASHTAG_NAME_RE}\z/i }

  scope :find_by_fee_range, ->(fee, range) { where("name like '%usd' and to_number(translate(name, 'usd', ''), '00000000') between ? and ?", fee - range, fee + range) }

  def to_param
    name
  end

  class << self
    def search_for(term, limit = 5)
      #pattern = sanitize_sql_like(term) + '%'
      #Tag.where('name like ?', pattern).order(:name).limit(limit)
      tags = term.split(' ')
      if tags.length == 1
        pattern = sanitize_sql_like(term.strip) + '%'
        Tag.joins(:statuses).where('lower(name) like lower(?)', pattern).order(:name).distinct.limit(limit)
      else
        sql = <<-SQL
          SELECT
            ARRAY_TO_STRING(
              ARRAY( SELECT name FROM tags WHERE name IN (:tags)), ' '
            ) AS name
          FROM tags
          LIMIT 1
        SQL
        Tag.find_by_sql([sql, {:tags => tags}])
      end
    end
  end
end
