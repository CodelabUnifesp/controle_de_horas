# == Schema Information
#
# Table name: event_assignments
#
#  id         :bigint           not null, primary key
#  event_id   :bigint           not null
#  member_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EventAssignment < ApplicationRecord
  belongs_to :event
  belongs_to :member

  validate :member_is_in_event_teams

  private

  def member_is_in_event_teams
    return if member.teams.any? { |team| event.teams.include?(team) }

    errors.add(:member, 'não faz parte de nenhum dos times do evento')
  end
end
