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
require 'rails_helper'

RSpec.describe Member, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
