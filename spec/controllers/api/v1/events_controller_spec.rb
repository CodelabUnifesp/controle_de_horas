require 'rails_helper'

RSpec.describe 'Events API', type: :request do
  let!(:user) { create(:user) }
  let(:auth_header) { auth_headers_for(user) }
  let!(:team) { create(:team) }
  let!(:member) { create(:member) }

  let!(:old_event) do
    event = build(:event, occurred_at: 10.days.ago, title: 'Old Event')
    event.teams << team
    event.save!
    event
  end
  let!(:middle_event) do
    event = build(:event, occurred_at: 5.days.ago, title: 'Middle Event')
    event.teams << team
    event.save!
    event
  end
  let!(:new_event) do
    event = build(:event, occurred_at: 1.day.ago, title: 'New Event')
    event.teams << team
    event.save!
    event
  end

  before do
    create(:membership, member: member, team: team)
    create(:event_assignment, event: old_event, member: member)
  end

  describe 'GET /api/v1/events' do
    it 'requires authentication' do
      get '/api/v1/events'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with authentication' do
      it 'returns all events by default ordered by occurred_at desc' do
        get '/api/v1/events', headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to eq(['New Event', 'Middle Event', 'Old Event'])
      end

      it 'filters by occurred_from (inclusive)' do
        get "/api/v1/events?occurred_from=#{5.days.ago.to_date}", headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to include('New Event', 'Middle Event')
        expect(titles).not_to include('Old Event')
      end

      it 'filters by occurred_to (inclusive)' do
        get "/api/v1/events?occurred_to=#{5.days.ago.to_date}", headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to include('Old Event', 'Middle Event')
        expect(titles).not_to include('New Event')
      end

      it 'filters by occurred_from and occurred_to' do
        params = {
          occurred_from: 6.days.ago.to_date,
          occurred_to: 2.days.ago.to_date
        }
        get '/api/v1/events', params: params, headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to eq(['Middle Event'])
      end

      it 'filters by team' do
        team2 = create(:team)
        event = build(:event, title: 'Team 2 Event')
        event.teams << team2
        event.save!

        get "/api/v1/events?team_ids[]=#{team.id}", headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }

        expect(titles).to contain_exactly('New Event', 'Middle Event', 'Old Event')
        expect(titles).not_to include('Team 2 Event')
      end

      it 'filters by member' do
        get "/api/v1/events?member_id=#{member.id}", headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }

        expect(titles).to contain_exactly('Old Event')
      end

      it 'filters by search term' do
        get '/api/v1/events?search=Middle', headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to contain_exactly('Middle Event')
      end

      it 'supports sorting by occurred_at asc' do
        get '/api/v1/events?sort_by=occurred_at&sort_order=asc', headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to eq(['Old Event', 'Middle Event', 'New Event'])
      end
    end
  end

  describe 'POST /api/v1/events' do
    it 'requires authentication' do
      post '/api/v1/events', params: { title: 'Test Event' }
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with authentication' do
      it 'creates event with team_ids and member_ids' do
        event_params = {
          title: 'Test Event',
          description: 'Test Description',
          duration_seconds: 900,
          occurred_at: '2025-06-01',
          team_ids: [team.id],
          member_ids: [member.id]
        }

        expect do
          post '/api/v1/events', params: event_params, headers: auth_header
        end.to change(Event, :count).by(1)

        expect(response).to have_http_status(:created)

        created_event = Event.last
        expect(created_event.title).to eq('Test Event')
        expect(created_event.teams).to include(team)
        expect(created_event.members).to include(member)
      end

      it 'returns error when event is invalid' do
        event_params = {
          title: '',
          duration_seconds: 900,
          occurred_at: '2025-06-01',
          team_ids: [team.id]
        }

        post '/api/v1/events', params: event_params, headers: auth_header

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include("Title can't be blank")
      end
    end
  end
end
