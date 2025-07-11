class AddOccurredAtToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :occurred_at, :datetime
  end
end
