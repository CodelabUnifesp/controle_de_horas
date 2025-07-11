# == Schema Information
#
# Table name: event_teams
#
#  id         :bigint           not null, primary key
#  event_id   :bigint           not null
#  team_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EventTeam < ApplicationRecord
  belongs_to :event
  belongs_to :team

  validates :event_id, uniqueness: { scope: :team_id }
end
