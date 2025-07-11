# == Schema Information
#
# Table name: teams
#
#  id          :bigint           not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships
  has_many :event_teams, dependent: :destroy
  has_many :events, through: :event_teams

  validates :name, presence: true,
                   length: { minimum: 3, maximum: 100, message: 'Nome deve ter entre 3 e 100 caracteres' }
end
