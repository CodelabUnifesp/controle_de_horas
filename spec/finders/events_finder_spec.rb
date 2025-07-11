require 'rails_helper'

RSpec.describe EventsFinder, type: :finder do
  let!(:team1) { create(:team, name: 'Team A') }
  let!(:team2) { create(:team, name: 'Team B') }
  let!(:member1) { create(:member) }
  let!(:member2) { create(:member) }

  let!(:event1) do
    event = build(:event, occurred_at: 10.days.ago, title: 'Old Event')
    event.teams << team1
    event.save!
    event
  end
  let!(:event2) do
    event = build(:event, occurred_at: 5.days.ago, title: 'Middle Event')
    event.teams << team1
    event.save!
    event
  end
  let!(:event3) do
    event = build(:event, occurred_at: 1.day.ago, title: 'Recent Event')
    event.teams << team2
    event.save!
    event
  end

  before do
    member1.teams << team1
    member2.teams << team1
    member1.teams << team2
    member2.teams << team2
    create(:event_assignment, event: event1, member: member1)
    create(:event_assignment, event: event2, member: member2)
    create(:event_assignment, event: event3, member: member1)
    create(:event_assignment, event: event3, member: member2)
  end

  describe '#perform' do
    context 'without filters' do
      it 'returns events ordered by occurred_at desc by default' do
        result = described_class.new({}).perform
        expect(result.map(&:title)).to eq(['Recent Event', 'Middle Event', 'Old Event'])
      end
    end

    context 'when filtering by team' do
      it 'returns events for a single team' do
        result = described_class.new(team_ids: [team1.id]).perform
        expect(result).to contain_exactly(event1, event2)
      end

      it 'returns events for multiple teams' do
        result = described_class.new(team_ids: [team1.id, team2.id]).perform
        expect(result).to contain_exactly(event1, event2, event3)
      end
    end

    context 'when filtering by member' do
      it 'returns events for a specific member' do
        result = described_class.new(member_id: member1.id).perform
        expect(result).to contain_exactly(event1, event3)
      end
    end

    context 'when filtering by search term' do
      it 'returns events matching the search term' do
        result = described_class.new(search: 'Recent').perform
        expect(result).to contain_exactly(event3)
      end
    end

    context 'when filtering by date range' do
      it 'filters by occurred_from only (inclusive)' do
        result = described_class.new(occurred_from: 5.days.ago.to_date.to_s).perform
        expect(result).to contain_exactly(event2, event3)
      end

      it 'filters by occurred_to only (inclusive)' do
        result = described_class.new(occurred_to: 5.days.ago.to_date.to_s).perform
        expect(result).to contain_exactly(event1, event2)
      end

      it 'filters by both occurred_from and occurred_to' do
        params = {
          occurred_from: 6.days.ago.to_date.to_s,
          occurred_to: 2.days.ago.to_date.to_s
        }
        result = described_class.new(params).perform
        expect(result).to contain_exactly(event2)
      end
    end

    context 'with combined filters' do
      it 'applies all filters together' do
        params = {
          team_ids: [team1.id],
          member_id: member1.id,
          occurred_from: 12.days.ago.to_date.to_s,
          search: 'Old'
        }
        result = described_class.new(params).perform
        expect(result).to contain_exactly(event1)
      end
    end

    context 'when sorting' do
      it 'sorts by occurred_at asc' do
        result = described_class.new(sort_by: 'occurred_at', sort_order: 'asc').perform
        expect(result.map(&:title)).to eq(['Old Event', 'Middle Event', 'Recent Event'])
      end

      it 'sorts by title' do
        result = described_class.new(sort_by: 'title', sort_order: 'asc').perform
        expect(result.map(&:title)).to eq(['Middle Event', 'Old Event', 'Recent Event'])
      end

      it 'sorts by team name' do
        team_c = create(:team, name: 'Team C')
        event_c = build(:event, title: 'Another Event')
        event_c.teams << team_c
        event_c.save!
        result = described_class.new(sort_by: 'team_name', sort_order: 'asc').perform
        expect(result.map { |e| e.teams.first.name }).to eq(['Team A', 'Team A', 'Team B', 'Team C'])
      end
    end
  end
end
