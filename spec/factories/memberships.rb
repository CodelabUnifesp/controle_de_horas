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
FactoryBot.define do
  factory :membership do
    association :team
    association :member
    role { :member }

    trait :leader do
      role { :leader }
    end
  end
end
