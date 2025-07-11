require 'rails_helper'

RSpec.describe TeamsFinder, type: :finder do
  let!(:team_alpha) { create(:team, name: 'Alpha Team') }
  let!(:team_beta) { create(:team, name: 'Beta Team') }
  let!(:team_gamma) { create(:team, name: 'Gamma Team') }

  let!(:member1) { create(:member, name: 'John Doe') }
  let!(:member2) { create(:member, name: 'Jane Smith') }
  let!(:member3) { create(:member, name: 'Bob Wilson') }

  before do
    create(:membership, team: team_alpha, member: member1)
    create(:membership, team: team_alpha, member: member2)
    create(:membership, team: team_beta, member: member3)
  end

  describe '#perform' do
    context 'when without filters' do
      it 'returns all teams ordered by name asc by default' do
        result = described_class.new({}).perform

        expect(result.map(&:name)).to eq(['Alpha Team', 'Beta Team', 'Gamma Team'])
      end

      it 'includes member count for each team' do
        result = described_class.new({}).perform

        alpha_team = result.find { |t| t.name == 'Alpha Team' }
        beta_team = result.find { |t| t.name == 'Beta Team' }
        gamma_team = result.find { |t| t.name == 'Gamma Team' }

        expect(alpha_team.member_count).to eq(2)
        expect(beta_team.member_count).to eq(1)
        expect(gamma_team.member_count).to eq(0)
      end
    end

    context 'when filtering by name' do
      it 'filters by partial name match case insensitive' do
        result = described_class.new(name: 'alpha').perform

        expect(result.map(&:name)).to eq(['Alpha Team'])
      end

      it 'returns empty when no match found' do
        result = described_class.new(name: 'nonexistent').perform

        expect(result).to be_empty
      end

      it 'handles special characters in search' do
        create(:team, name: 'Team-Special')
        result = described_class.new(name: 'special').perform

        expect(result.map(&:name)).to eq(['Team-Special'])
      end
    end

    context 'when sorting' do
      it 'sorts by name asc' do
        result = described_class.new(sort_by: 'name', sort_order: 'asc').perform

        expect(result.map(&:name)).to eq(['Alpha Team', 'Beta Team', 'Gamma Team'])
      end

      it 'sorts by name desc' do
        result = described_class.new(sort_by: 'name', sort_order: 'desc').perform

        expect(result.map(&:name)).to eq(['Gamma Team', 'Beta Team', 'Alpha Team'])
      end

      it 'sorts by member count asc' do
        result = described_class.new(sort_by: 'member_count', sort_order: 'asc').perform

        expect(result.map(&:name)).to eq(['Gamma Team', 'Beta Team', 'Alpha Team'])
      end

      it 'sorts by member count desc' do
        result = described_class.new(sort_by: 'member_count', sort_order: 'desc').perform

        expect(result.map(&:name)).to eq(['Alpha Team', 'Beta Team', 'Gamma Team'])
      end

      it 'defaults to name asc when invalid sort_by' do
        result = described_class.new(sort_by: 'invalid', sort_order: 'desc').perform

        expect(result.map(&:name)).to eq(['Alpha Team', 'Beta Team', 'Gamma Team'])
      end

      it 'defaults to asc when invalid sort_order' do
        result = described_class.new(sort_by: 'name', sort_order: 'invalid').perform

        expect(result.map(&:name)).to eq(['Alpha Team', 'Beta Team', 'Gamma Team'])
      end
    end

    context 'when combining filters and sorting' do
      it 'combines name filter with sorting' do
        create(:team, name: 'Another Alpha Team')

        result = described_class.new(
          name: 'alpha',
          sort_by: 'name',
          sort_order: 'desc'
        ).perform

        expect(result.map(&:name)).to eq(['Another Alpha Team', 'Alpha Team'])
      end

      it 'applies member count sorting with name filter' do
        alpha_team2 = create(:team, name: 'Alpha Team 2')
        create(:membership, team: alpha_team2, member: create(:member))
        create(:membership, team: alpha_team2, member: create(:member))
        create(:membership, team: alpha_team2, member: create(:member))

        result = described_class.new(
          name: 'alpha',
          sort_by: 'member_count',
          sort_order: 'desc'
        ).perform

        expect(result.first.name).to eq('Alpha Team 2')
        expect(result.first.member_count).to eq(3)
      end
    end
  end
end
