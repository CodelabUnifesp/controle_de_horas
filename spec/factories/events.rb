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
FactoryBot.define do
  factory :event do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    duration_seconds { [15.minutes, 30.minutes, 1.hour, 2.hours].sample.to_i }
    occurred_at { Faker::Date.between(from: 30.days.ago, to: Time.zone.today) }

    trait :with_team do
      after(:create) do |event|
        team = create(:team)
        event.teams << team
      end
    end

    trait :with_teams do
      transient do
        teams_count { 2 }
      end

      after(:create) do |event, evaluator|
        evaluator.teams_count.times do
          event.teams << create(:team)
        end
      end
    end
  end
end
