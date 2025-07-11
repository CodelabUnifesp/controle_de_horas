class AddDisabledAtToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :disabled_at, :datetime, null: true
  end
end
