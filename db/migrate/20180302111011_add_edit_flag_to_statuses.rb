class AddEditFlagToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :edited, :boolean, null: true, default: nil
  end
end
