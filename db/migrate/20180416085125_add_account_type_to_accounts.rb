require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddAccountTypeToAccounts < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :accounts, :account_type, :integer, default: 0, allow_null: false
    end
    add_index :accounts, :account_type, algorithm: :concurrently
  end

  def down
    remove_index :accounts, :account_type
    remove_column :accounts, :account_type
  end
end
