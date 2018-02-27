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
    init_tags = [
      ['Grade_A', 'Grade A'],
      ['Grade_B', 'Grade B'],
      ['Grade_C', 'Grade C'],
      ['Bizcenter', 'Bizcenter'],
      ['Other', 'Other']
    ]

    init_tags.each do |t|
      if !tag = Tag.find_by(name: t[0])
        tag = Tag.create(name: t[0])
      end
      SuggestionTag.create(tag_id: tag.id, description: t[1])
    end
  end
end
