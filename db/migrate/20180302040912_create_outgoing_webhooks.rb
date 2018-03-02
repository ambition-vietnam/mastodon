class CreateOutgoingWebhooks < ActiveRecord::Migration[5.1]
  def change
    create_table :outgoing_webhooks do |t|
      t.string :name, null: false
      t.string :url, null: false, default: ''
      t.string :trigger_word, null: false, default: ''
      t.string :token, null: false, default: ''

      t.timestamps
    end
  end
end
