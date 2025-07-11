class CreateEventTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :event_teams do |t|
      t.references :event, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.index %i[event_id team_id], unique: true

      t.timestamps
    end
  end
end
