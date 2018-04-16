class AddAccountTypeToAccounts < ActiveRecord::Migration[5.1]
  def up
    add_column :accounts, :account_type, :integer
    Account.in_batches.update_all account_type: 0
    change_column_default :accounts, :account_type, 0
    change_column_null :accounts, :account_type, false
  end

  def down
    remove_column :accounts, :account_type
  end
end
