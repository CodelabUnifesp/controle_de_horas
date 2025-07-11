# == Schema Information
#
# Table name: jwt_denylist
#
#  id         :bigint           not null, primary key
#  jti        :string           not null
#  exp        :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  it 'includes the denylist revocation strategy module' do
    expect(described_class.ancestors).to include(Devise::JWT::RevocationStrategies::Denylist)
  end
end
