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
require 'rails_helper'

RSpec.describe Membership, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
