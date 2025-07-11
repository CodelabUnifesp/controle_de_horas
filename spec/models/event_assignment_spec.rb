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
require 'rails_helper'

RSpec.describe EventAssignment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
