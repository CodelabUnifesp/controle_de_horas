require 'rails_helper'

RSpec.describe 'Super Admin Members API', type: :request do
  let!(:super_admin_user) { create(:user, super_admin: true) }
  let!(:active_member) { create(:member, name: 'John Doe', active: true) }
  let!(:inactive_member) { create(:member, name: 'Jane Smith', active: false) }
  let(:auth_header) { auth_headers_for(super_admin_user) }

  describe 'GET /api/v1/super_admin/members' do
    it 'requires authentication' do
      get '/api/v1/super_admin/members'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with super admin authentication' do
      it 'returns all members with pagination info' do
        get '/api/v1/super_admin/members', headers: auth_header

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['records']).to be_present
        expect(json['total_pages']).to be_present
        expect(json['current_page']).to be_present
        expect(json['total_count']).to be_present

        member_names = json['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe', 'Jane Smith')
      end

      it 'filters by active status' do
        # Apenas ativos
        get '/api/v1/super_admin/members?active=true', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')

        # Apenas inativos
        get '/api/v1/super_admin/members?active=false', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('Jane Smith')
        expect(member_names).not_to include('John Doe')
      end

      it 'filters by teams' do
        team1 = create(:team, name: 'Frontend')
        team2 = create(:team, name: 'Backend')

        team1.memberships.create!(member: active_member)
        team2.memberships.create!(member: inactive_member)

        # Filtra por time específico
        get "/api/v1/super_admin/members?team_ids[]=#{team1.id}", headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')
      end

      it 'filters by external_id' do
        create(:member, name: 'Member with ID', external_id: '12345678901')
        create(:member, name: 'Member without ID', external_id: nil)

        get '/api/v1/super_admin/members?external_id=12345678901', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('Member with ID')
        expect(member_names).not_to include('Member without ID', 'John Doe', 'Jane Smith')
      end

      it 'supports sorting' do
        create(:member, name: 'Alice', active: true)
        create(:member, name: 'Bob', active: true)

        # Ordenação crescente
        get '/api/v1/super_admin/members?sort_by=name&sort_order=asc', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names.first(3)).to eq(['Alice', 'Bob', 'Jane Smith'])
      end

      context 'with hours calculation' do
        let!(:team) { create(:team) }
        let!(:event1) do
          event = build(:event, duration_seconds: 3600)
          event.teams << team
          event.save!
          event
        end
        let!(:event2) do
          event = build(:event, duration_seconds: 1800)
          event.teams << team
          event.save!
          event
        end

        before do
          active_member.teams << team
          create(:event_assignment, member: active_member, event: event1)
          create(:event_assignment, member: active_member, event: event2)
        end

        it 'returns members with their hour calculations' do
          get '/api/v1/super_admin/members?with_hours=true', headers: auth_header
          expect(response).to have_http_status(:ok)

          json = response.parsed_body['records']
          active_member_data = json.find { |m| m['id'] == active_member.id }
          inactive_member_data = json.find { |m| m['id'] == inactive_member.id }

          expect(active_member_data['event_count']).to eq(2)
          expect(active_member_data['total_seconds']).to eq(5400)
          expect(inactive_member_data['event_count']).to eq(0)
          expect(inactive_member_data['total_seconds']).to eq(0)
        end

        it 'sorts by total_hours' do
          get '/api/v1/super_admin/members?with_hours=true&sort_by=total_hours&sort_order=desc', headers: auth_header

          json = response.parsed_body['records']
          ids = json.map { |m| m['id'] }
          expect(ids.first).to eq(active_member.id)

          get '/api/v1/super_admin/members?with_hours=true&sort_by=total_hours&sort_order=asc', headers: auth_header

          json = response.parsed_body['records']
          ids = json.map { |m| m['id'] }
          expect(ids.first).to eq(inactive_member.id)
        end
      end
    end
  end

  describe 'GET /api/v1/super_admin/members/:id' do
    it 'requires authentication' do
      get "/api/v1/super_admin/members/#{active_member.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns member details with teams and memberships' do
      team = create(:team, name: 'Development')
      team.memberships.create!(member: active_member)

      get "/api/v1/super_admin/members/#{active_member.id}", headers: auth_header

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['record']['name']).to eq('John Doe')
      expect(json['teams']).to be_present
      expect(json['memberships']).to be_present
    end

    it 'returns 404 for non-existent member' do
      get '/api/v1/super_admin/members/0', headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/super_admin/members' do
    it 'requires authentication' do
      post '/api/v1/super_admin/members', params: { name: 'New Member' }
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with super admin authentication' do
      it 'creates a new member' do
        expect do
          post '/api/v1/super_admin/members',
               params: { name: 'New Member', pix_key: '123456789' },
               headers: auth_header
        end.to change(Member, :count).by(1)

        expect(response).to be_successful
      end

      it 'validates presence of name' do
        post '/api/v1/super_admin/members',
             params: { name: '' },
             headers: auth_header

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PATCH /api/v1/super_admin/members/:id' do
    it 'requires authentication' do
      patch "/api/v1/super_admin/members/#{active_member.id}", params: { name: 'Updated' }
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with super admin authentication' do
      it 'updates member data' do
        patch "/api/v1/super_admin/members/#{active_member.id}",
              params: { name: 'John Updated', pix_key: '987654321', active: false },
              headers: auth_header

        expect(response).to be_successful

        active_member.reload
        expect(active_member.name).to eq('John Updated')
        expect(active_member.pix_key).to eq('987654321')
        expect(active_member.active).to be false
      end

      it 'validates presence of name on update' do
        patch "/api/v1/super_admin/members/#{active_member.id}",
              params: { name: '' },
              headers: auth_header

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include("Name can't be blank")
      end

      it 'returns 404 for non-existent member' do
        patch '/api/v1/super_admin/members/0',
              params: { name: 'Updated' },
              headers: auth_header
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
