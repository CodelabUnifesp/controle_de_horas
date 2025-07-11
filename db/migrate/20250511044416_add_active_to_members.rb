class AddActiveToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :active, :boolean, default: true
  end
end
