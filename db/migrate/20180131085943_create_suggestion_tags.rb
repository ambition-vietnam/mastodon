class CreateSuggestionTags < ActiveRecord::Migration[5.1]
  def change
    create_table :suggestion_tags do |t|
      t.integer :tag_id, null: false
      t.integer :order, null: false, default: 1
      t.integer :suggestion_type, null: false, default: 0
      t.string :description, null: false, default: ''
      t.timestamps

      t.index [:tag_id, :suggestion_type], unique: true
    end
    init
  end

  private

  def init
    init_tags = [ 'Grade_A', 'Grade_B', 'Grade_C', 'Bizcenter', 'Other' ]

    init_tags.each do |t|
      if !tag = Tag.find_by(name: t)
        tag = Tag.create(name: t)
      end
      SuggestionTag.create(tag_id: tag.id, description: t)
    end
  end
end
