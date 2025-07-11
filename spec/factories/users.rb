# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  suspended              :boolean          default(FALSE)
#  super_admin            :boolean          default(FALSE)
#
FactoryBot.define do
  factory :user do
    email { Faker::Name.name + "@#{SecureRandom.uuid}.com" }
    password { 'Password1!' }
  end
end
