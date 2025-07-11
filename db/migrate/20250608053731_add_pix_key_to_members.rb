class AddPixKeyToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :pix_key, :string
    add_index :members, :pix_key, unique: true
  end
end
