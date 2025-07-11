# == Schema Information
#
# Table name: memberships
#
#  id         :bigint           not null, primary key
#  team_id    :bigint           not null
#  member_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role       :integer          default("member")
#
class Membership < ApplicationRecord
  enum role: {
    member: 0,
    leader: 1
  }

  belongs_to :team
  belongs_to :member
end
