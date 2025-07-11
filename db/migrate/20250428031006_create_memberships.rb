class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships do |t|
      t.references :team, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end
    add_index :memberships, [:member_id, :team_id], unique: true
  end
end
