require 'rails_helper'

RSpec.describe MembersFinder do
  describe '#perform' do
    let!(:active_member) { create(:member, name: 'John Doe', active: true) }
    let!(:inactive_member) { create(:member, name: 'Jane Smith', active: false) }
    let!(:another_active) { create(:member, name: 'Alice Active', active: true) }

    let!(:team_frontend) { create(:team, name: 'Frontend') }
    let!(:team_backend) { create(:team, name: 'Backend') }

    before do
      # Associa membros aos times
      team_frontend.memberships.create!(member: active_member)
      team_frontend.memberships.create!(member: another_active)
      team_backend.memberships.create!(member: inactive_member)
    end

    context 'when without filters' do
      it 'returns all members ordered by name asc by default' do
        result = described_class.new({}).perform

        expect(result.map(&:name)).to eq(['Alice Active', 'Jane Smith', 'John Doe'])
      end
    end

    context 'when filtering by active status' do
      it 'filters active members' do
        result = described_class.new(active: true).perform

        expect(result).to include(active_member, another_active)
        expect(result).not_to include(inactive_member)
      end

      it 'filters inactive members' do
        result = described_class.new(active: false).perform

        expect(result).to include(inactive_member)
        expect(result).not_to include(active_member, another_active)
      end

      it 'handles string values for active parameter' do
        # String 'true'
        result = described_class.new(active: 'true').perform
        expect(result).to include(active_member)
        expect(result).not_to include(inactive_member)

        # String '1'
        result = described_class.new(active: '1').perform
        expect(result).to include(active_member)
        expect(result).not_to include(inactive_member)

        # String 'false'
        result = described_class.new(active: 'false').perform
        expect(result).to include(inactive_member)
        expect(result).not_to include(active_member)
      end

      it 'returns all members when active is nil or invalid' do
        # Nil value
        result = described_class.new(active: nil).perform
        expect(result).to include(active_member, inactive_member)

        # Invalid value
        result = described_class.new(active: 'invalid').perform
        expect(result).to include(active_member, inactive_member)
      end
    end

    context 'when filtering by name' do
      it 'filters by partial name match case insensitive' do
        result = described_class.new(name: 'john').perform
        expect(result).to include(active_member)
        expect(result).not_to include(inactive_member, another_active)

        result = described_class.new(name: 'JOHN').perform
        expect(result).to include(active_member)
        expect(result).not_to include(inactive_member, another_active)
      end

      it 'returns empty when no name matches' do
        result = described_class.new(name: 'NonExistent').perform
        expect(result).to be_empty
      end
    end

    context 'when filtering by external_id' do
      let!(:member_with_external_id) { create(:member, external_id: '12345678901') }
      let!(:member_with_another_external_id) { create(:member, external_id: '98765432100') }

      it 'filters by exact external_id match' do
        result = described_class.new(external_id: '12345678901').perform
        expect(result).to include(member_with_external_id)
        expect(result).not_to include(member_with_another_external_id, active_member, inactive_member)
      end

      it 'returns empty when no external_id matches' do
        result = described_class.new(external_id: '00000000000').perform
        expect(result).to be_empty
      end

      it 'returns empty when external_id is blank' do
        result = described_class.new(external_id: '').perform
        expect(result).to include(active_member, inactive_member, another_active, member_with_external_id,
                                  member_with_another_external_id)
      end
    end

    context 'when filtering by teams' do
      it 'filters by single team' do
        result = described_class.new(team_ids: [team_frontend.id]).perform

        expect(result).to include(active_member, another_active)
        expect(result).not_to include(inactive_member)
      end

      it 'filters by multiple teams' do
        result = described_class.new(team_ids: [team_frontend.id, team_backend.id]).perform

        expect(result).to include(active_member, another_active, inactive_member)
      end

      it 'handles string team ids' do
        result = described_class.new(team_ids: [team_frontend.id.to_s]).perform

        expect(result).to include(active_member, another_active)
        expect(result).not_to include(inactive_member)
      end
    end

    context 'when sorting' do
      it 'sorts by name asc' do
        result = described_class.new(sort_by: 'name', sort_order: 'asc').perform
        expect(result.map(&:name)).to eq(['Alice Active', 'Jane Smith', 'John Doe'])
      end

      it 'sorts by name desc' do
        result = described_class.new(sort_by: 'name', sort_order: 'desc').perform
        expect(result.map(&:name)).to eq(['John Doe', 'Jane Smith', 'Alice Active'])
      end

      it 'sorts by created_at' do
        result = described_class.new(sort_by: 'created_at', sort_order: 'asc').perform
        expect(result.to_a).to eq([active_member, inactive_member, another_active])
      end

      it 'defaults to name asc for invalid sort_by' do
        result = described_class.new(sort_by: 'invalid', sort_order: 'desc').perform
        expect(result.map(&:name)).to eq(['Alice Active', 'Jane Smith', 'John Doe'])
      end
    end

    context 'when combining filters' do
      it 'combines active status and team filters' do
        result = described_class.new(
          active: true,
          team_ids: [team_frontend.id]
        ).perform

        expect(result).to include(active_member, another_active)
        expect(result).not_to include(inactive_member)
      end

      it 'combines name search and team filters' do
        result = described_class.new(
          name: 'john',
          team_ids: [team_frontend.id]
        ).perform

        expect(result).to include(active_member)
        expect(result).not_to include(another_active, inactive_member)
      end

      it 'combines all filters with sorting' do
        result = described_class.new(
          active: true,
          team_ids: [team_frontend.id],
          name: 'a',
          sort_by: 'name',
          sort_order: 'desc'
        ).perform

        expect(result.map(&:name)).to eq(['Alice Active'])
      end
    end

    context 'with hours calculation' do
      let!(:event1) do
        event = build(:event, duration_seconds: 3600)
        event.teams << team_frontend
        event.save!
        event
      end
      let!(:event2) do
        event = build(:event, duration_seconds: 1800)
        event.teams << team_frontend
        event.save!
        event
      end
      let!(:event3) do
        event = build(:event, duration_seconds: 7200)
        event.teams << team_backend
        event.save!
        event
      end

      before do
        create(:event_assignment, member: active_member, event: event1)
        create(:event_assignment, member: active_member, event: event2)
        create(:event_assignment, member: inactive_member, event: event3)
      end

      it 'returns members with event_count and total_seconds' do
        result = described_class.new(with_hours: true).perform

        member1_result = result.find { |m| m.id == active_member.id }
        member2_result = result.find { |m| m.id == inactive_member.id }
        member3_result = result.find { |m| m.id == another_active.id }

        expect(member1_result.event_count).to eq(2)
        expect(member1_result.total_seconds).to eq(5400)

        expect(member2_result.event_count).to eq(1)
        expect(member2_result.total_seconds).to eq(7200)

        expect(member3_result.event_count).to eq(0)
        expect(member3_result.total_seconds).to eq(0)
      end

      it 'sorts by total_hours descending' do
        result = described_class.new(with_hours: true, sort_by: 'total_hours', sort_order: 'desc').perform
        expect(result.map(&:id)).to eq([inactive_member.id, active_member.id, another_active.id])
      end

      it 'sorts by total_hours ascending' do
        result = described_class.new(with_hours: true, sort_by: 'total_hours', sort_order: 'asc').perform
        expect(result.map(&:id)).to eq([another_active.id, active_member.id, inactive_member.id])
      end
    end
  end
end
