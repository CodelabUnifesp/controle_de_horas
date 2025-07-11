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
FactoryBot.define do
  factory :event_assignment do
    event
    member
  end
end
