# == Schema Information
#
# Table name: events
#
#  id               :bigint           not null, primary key
#  title            :string
#  description      :text
#  duration_seconds :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  occurred_at      :datetime
#
class Event < ApplicationRecord
  has_many :event_teams, dependent: :destroy
  has_many :teams, through: :event_teams
  has_many :event_assignments, dependent: :destroy
  has_many :members, through: :event_assignments

  validates :duration_seconds, numericality: { greater_than: 0 }
  validates :title, presence: true
  validates :occurred_at, presence: true
  validate :must_have_at_least_one_team

  private

  def must_have_at_least_one_team
    errors.add(:teams, 'deve ter pelo menos um time') if teams.empty?
  end
end
