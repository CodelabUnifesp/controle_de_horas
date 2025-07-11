require 'rails_helper'

RSpec.describe 'Teams API', type: :request do
  let!(:user) { create(:user) }
  let!(:team1) { create(:team, name: 'Frontend') }
  let!(:team2) { create(:team, name: 'Backend') }
  let!(:member1) { create(:member) }
  let!(:member2) { create(:member) }
  let!(:member3) { create(:member) }
  let(:auth_header) { auth_headers_for(user) }

  describe 'GET /api/v1/teams' do
    it 'requires authentication' do
      get '/api/v1/teams'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with authentication' do
      it 'returns all teams by default' do
        get '/api/v1/teams', headers: auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to include('Frontend', 'Backend')
      end

      it 'filters by name' do
        get '/api/v1/teams?name=Front', headers: auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to include('Frontend')
        expect(team_names).not_to include('Backend')
      end

      it 'supports sorting by name' do
        # Ordenação crescente
        get '/api/v1/teams?sort_by=name&sort_order=asc', headers: auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to eq(%w[Backend Frontend])

        # Ordenação decrescente
        get '/api/v1/teams?sort_by=name&sort_order=desc', headers: auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to eq(%w[Frontend Backend])
      end

      it 'supports sorting by member count' do
        member1 = create(:member)
        member2 = create(:member)
        team1.memberships.create!(member: member1)
        team1.memberships.create!(member: member2)
        team2.memberships.create!(member: member1)

        # Ordenação crescente por número de membros
        get '/api/v1/teams?sort_by=member_count&sort_order=asc', headers: auth_header
        teams = response.parsed_body['records']
        expect(teams.first['name']).to eq('Backend')
        expect(teams.last['name']).to eq('Frontend')

        # Ordenação decrescente por número de membros
        get '/api/v1/teams?sort_by=member_count&sort_order=desc', headers: auth_header
        teams = response.parsed_body['records']
        expect(teams.first['name']).to eq('Frontend')
        expect(teams.last['name']).to eq('Backend')
      end
    end
  end

  describe 'GET /api/v1/teams/:id' do
    it 'requires authentication' do
      get "/api/v1/teams/#{team1.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns team details and members' do
      team1.members << [member1, member2]

      get "/api/v1/teams/#{team1.id}", headers: auth_header
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['record']['name']).to eq('Frontend')
      expect(json['members'].count).to eq(2)
      expect(json['members'].map { |m| m['id'] }).to contain_exactly(member1.id, member2.id)
    end

    it 'returns 404 for non-existent team' do
      get '/api/v1/teams/0', headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/teams' do
    it 'returns method not allowed' do
      post '/api/v1/teams', params: { name: 'New Team' }, headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/v1/teams/:id' do
    it 'returns method not allowed' do
      patch "/api/v1/teams/#{team1.id}", params: { name: 'Updated Team' }, headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/teams/:id' do
    it 'returns method not allowed' do
      delete "/api/v1/teams/#{team1.id}", headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end
end
