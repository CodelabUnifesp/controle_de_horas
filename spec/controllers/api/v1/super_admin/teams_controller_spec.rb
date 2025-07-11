require 'rails_helper'

RSpec.describe 'Super Admin Teams API', type: :request do
  let!(:regular_user) { create(:user, super_admin: false) }
  let!(:super_admin_user) { create(:user, super_admin: true) }
  let!(:team1) { create(:team, name: 'Frontend') }
  let!(:team2) { create(:team, name: 'Backend') }
  let!(:member1) { create(:member) }
  let!(:member2) { create(:member) }
  let!(:member3) { create(:member) }
  let(:regular_auth_header) { auth_headers_for(regular_user) }
  let(:super_admin_auth_header) { auth_headers_for(super_admin_user) }

  describe 'GET /api/v1/super_admin/teams' do
    it 'requires authentication' do
      get '/api/v1/super_admin/teams'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'requires super admin access' do
      get '/api/v1/super_admin/teams', headers: regular_auth_header
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('super admin')
    end

    context 'with super admin authentication' do
      it 'returns all teams by default' do
        get '/api/v1/super_admin/teams', headers: super_admin_auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to include('Frontend', 'Backend')
      end

      it 'filters by name' do
        get '/api/v1/super_admin/teams?name=Front', headers: super_admin_auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to include('Frontend')
        expect(team_names).not_to include('Backend')
      end

      it 'supports sorting by name' do
        get '/api/v1/super_admin/teams?sort_by=name&sort_order=asc', headers: super_admin_auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to eq(%w[Backend Frontend])

        get '/api/v1/super_admin/teams?sort_by=name&sort_order=desc', headers: super_admin_auth_header
        team_names = response.parsed_body['records'].map { |t| t['name'] }
        expect(team_names).to eq(%w[Frontend Backend])
      end

      it 'supports sorting by member count' do
        team1.memberships.create!(member: member1)
        team1.memberships.create!(member: member2)
        team2.memberships.create!(member: member1)

        get '/api/v1/super_admin/teams?sort_by=member_count&sort_order=asc', headers: super_admin_auth_header
        teams = response.parsed_body['records']
        expect(teams.first['name']).to eq('Backend')
        expect(teams.last['name']).to eq('Frontend')

        get '/api/v1/super_admin/teams?sort_by=member_count&sort_order=desc', headers: super_admin_auth_header
        teams = response.parsed_body['records']
        expect(teams.first['name']).to eq('Frontend')
        expect(teams.last['name']).to eq('Backend')
      end
    end
  end

  describe 'GET /api/v1/super_admin/teams/:id' do
    it 'requires authentication' do
      get "/api/v1/super_admin/teams/#{team1.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'requires super admin access' do
      get "/api/v1/super_admin/teams/#{team1.id}", headers: regular_auth_header
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('super admin')
    end

    context 'with super admin authentication' do
      it 'returns team details and members' do
        team1.members << [member1, member2]

        get "/api/v1/super_admin/teams/#{team1.id}", headers: super_admin_auth_header
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json['record']['name']).to eq('Frontend')
        expect(json['members'].count).to eq(2)
        expect(json['members'].map { |m| m['id'] }).to contain_exactly(member1.id, member2.id)
      end

      it 'returns 404 for non-existent team' do
        get '/api/v1/super_admin/teams/0', headers: super_admin_auth_header
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/super_admin/teams' do
    it 'requires authentication' do
      post '/api/v1/super_admin/teams', params: { name: 'New Team' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'requires super admin access' do
      post '/api/v1/super_admin/teams', params: { name: 'New Team' }, headers: regular_auth_header
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('super admin')
    end

    context 'with super admin authentication' do
      it 'creates a new team without members' do
        expect do
          post '/api/v1/super_admin/teams',
               params: { name: 'DevOps' },
               headers: super_admin_auth_header
        end.to change(Team, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(Team.last.name).to eq('DevOps')
        expect(Team.last.members).to be_empty
      end

      it 'creates a new team with members' do
        expect do
          post '/api/v1/super_admin/teams',
               params: { name: 'DevOps', member_ids: [member1.id, member2.id] },
               headers: super_admin_auth_header
        end.to change(Team, :count).by(1)

        expect(response).to have_http_status(:success)
        new_team = Team.last
        expect(new_team.name).to eq('DevOps')
        expect(new_team.members.count).to eq(2)
        expect(new_team.members).to contain_exactly(member1, member2)
      end

      it 'validates presence of name' do
        post '/api/v1/super_admin/teams',
             params: { name: '' },
             headers: super_admin_auth_header

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PATCH /api/v1/super_admin/teams/:id' do
    it 'requires authentication' do
      patch "/api/v1/super_admin/teams/#{team1.id}", params: { name: 'Updated Team' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'requires super admin access' do
      patch "/api/v1/super_admin/teams/#{team1.id}", params: { name: 'Updated Team' }, headers: regular_auth_header
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('super admin')
    end

    context 'with super admin authentication' do
      it 'updates team name' do
        patch "/api/v1/super_admin/teams/#{team1.id}",
              params: { name: 'Frontend Updated' },
              headers: super_admin_auth_header

        expect(response).to have_http_status(:ok)
        expect(team1.reload.name).to eq('Frontend Updated')
      end

      context 'when managing members' do
        before { team1.members << member1 }

        it 'adds new members to a team' do
          patch "/api/v1/super_admin/teams/#{team1.id}",
                params: { member_ids: [member1.id, member2.id] },
                headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          expect(team1.reload.members.count).to eq(2)
          expect(team1.members).to contain_exactly(member1, member2)
        end

        it 'removes members from a team' do
          team1.members << member2
          patch "/api/v1/super_admin/teams/#{team1.id}",
                params: { member_ids: [member2.id] },
                headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          expect(team1.reload.members.count).to eq(1)
          expect(team1.members).to contain_exactly(member2)
        end

        it 'replaces all members of a team' do
          patch "/api/v1/super_admin/teams/#{team1.id}",
                params: { member_ids: [member2.id, member3.id] },
                headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          expect(team1.reload.members.count).to eq(2)
          expect(team1.members).to contain_exactly(member2, member3)
        end

        it 'removes all members when empty array is provided' do
          expect(team1.members.count).to be > 0

          patch "/api/v1/super_admin/teams/#{team1.id}",
                params: { member_ids: [] }.to_json,
                headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          expect(team1.reload.members.count).to eq(0)
        end
      end

      it 'validates presence of name on update' do
        patch "/api/v1/super_admin/teams/#{team1.id}",
              params: { name: '' },
              headers: super_admin_auth_header

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include("Name can't be blank")
      end

      it 'returns 404 for non-existent team' do
        patch '/api/v1/super_admin/teams/0',
              params: { name: 'Updated Team' },
              headers: super_admin_auth_header
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/super_admin/teams/:id' do
    it 'requires authentication' do
      delete "/api/v1/super_admin/teams/#{team1.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'requires super admin access' do
      delete "/api/v1/super_admin/teams/#{team1.id}", headers: regular_auth_header
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('super admin')
    end

    context 'with super admin authentication' do
      it 'deletes the team' do
        team_to_delete = create(:team, name: 'To Delete')
        expect do
          delete "/api/v1/super_admin/teams/#{team_to_delete.id}", headers: super_admin_auth_header
        end.to change(Team, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end

      it 'deletes team with members' do
        team_to_delete = create(:team, name: 'To Delete')
        team_to_delete.members << [member1, member2]

        expect do
          delete "/api/v1/super_admin/teams/#{team_to_delete.id}", headers: super_admin_auth_header
        end.to change(Team, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(Membership.where(team_id: team_to_delete.id)).to be_empty
      end

      it 'returns 404 for non-existent team' do
        delete '/api/v1/super_admin/teams/0', headers: super_admin_auth_header
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
