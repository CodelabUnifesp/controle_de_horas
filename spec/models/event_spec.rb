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
require 'rails_helper'

RSpec.describe Event, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
