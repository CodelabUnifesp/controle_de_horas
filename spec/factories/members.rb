# == Schema Information
#
# Table name: members
#
#  id          :bigint           not null, primary key
#  name        :string
#  email       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active      :boolean          default(TRUE)
#  pix_key     :string
#  disabled_at :datetime
#  external_id :string
#
FactoryBot.define do
  factory :member do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    pix_key { Faker::Alphanumeric.alphanumeric(number: 10) }
    active { true }
  end
end
