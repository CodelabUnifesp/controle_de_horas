class AddExternalIdToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :external_id, :string
  end
end
