class CreateTrendNgWords < ActiveRecord::Migration[5.1]
  def change
    create_table :trend_ng_words do |t|
      t.string :word, null: false, default: ''
      t.string :memo, null: false, default: ''
      t.timestamps

      t.index :word, unique: true
    end
  end
end
