require 'rails_helper'

describe UserFinder do
  let!(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }

  describe '#perform' do
    it 'returns the report for the current user' do
      fetched_user = described_class.new(token).perform
      expect(fetched_user.id).to eq(user.id)
    end
  end
end
