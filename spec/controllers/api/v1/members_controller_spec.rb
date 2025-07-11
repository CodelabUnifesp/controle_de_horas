require 'rails_helper'

RSpec.describe 'Members API (Read-only)', type: :request do
  let!(:user) { create(:user, super_admin: false) }
  let!(:active_member) { create(:member, name: 'John Doe', active: true) }
  let!(:inactive_member) { create(:member, name: 'Jane Smith', active: false) }
  let(:auth_header) { auth_headers_for(user) }

  describe 'GET /api/v1/members' do
    it 'requires authentication' do
      get '/api/v1/members'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with authentication (regular user)' do
      it 'returns all members by default' do
        get '/api/v1/members', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe', 'Jane Smith')
      end

      it 'returns only active members when all_records is true' do
        get '/api/v1/members?all_records=true', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')
      end

      it 'filters by active status' do
        # Apenas ativos
        get '/api/v1/members?active=true', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')

        # Apenas inativos
        get '/api/v1/members?active=false', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('Jane Smith')
        expect(member_names).not_to include('John Doe')
      end

      it 'filters by teams' do
        team1 = create(:team, name: 'Frontend')
        team2 = create(:team, name: 'Backend')

        # Adiciona membros aos times
        team1.memberships.create!(member: active_member)
        team2.memberships.create!(member: inactive_member)

        # Filtra por time específico
        get "/api/v1/members?team_ids[]=#{team1.id}", headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')

        # Filtra por múltiplos times
        get "/api/v1/members?team_ids[]=#{team1.id}&team_ids[]=#{team2.id}", headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe', 'Jane Smith')
      end

      it 'combines filters (active + teams)' do
        team = create(:team, name: 'Development')
        team.memberships.create!(member: active_member)
        team.memberships.create!(member: inactive_member)

        # Apenas membros ativos do time Development
        get "/api/v1/members?active=true&team_ids[]=#{team.id}", headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')
      end

      it 'supports sorting' do
        create(:member, name: 'Alice', active: true)
        create(:member, name: 'Bob', active: true)

        # Ordenação crescente
        get '/api/v1/members?sort_by=name&sort_order=asc', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names.first(3)).to eq(['Alice', 'Bob', 'Jane Smith'])

        # Ordenação decrescente
        get '/api/v1/members?sort_by=name&sort_order=desc', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names.first(3)).to eq(['John Doe', 'Jane Smith', 'Bob'])
      end

      it 'searches by name' do
        get '/api/v1/members?name=John', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')
      end

      it 'filters by external_id' do
        create(:member, name: 'Member with ID', external_id: '12345678901')
        create(:member, name: 'Member without ID', external_id: nil)

        get '/api/v1/members?external_id=12345678901', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('Member with ID')
        expect(member_names).not_to include('Member without ID', 'John Doe', 'Jane Smith')
      end
    end
  end

  describe 'GET /api/v1/members/:id' do
    it 'requires authentication' do
      get "/api/v1/members/#{active_member.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns member details' do
      get "/api/v1/members/#{active_member.id}", headers: auth_header
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['record']['name']).to eq('John Doe')
    end

    it 'returns 404 for non-existent member' do
      get '/api/v1/members/0', headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end

  # Testes para verificar que operações de escrita NÃO estão disponíveis
  describe 'Write operations (should not be available)' do
    it 'does not allow PATCH requests' do
      patch "/api/v1/members/#{active_member.id}",
            params: { name: 'Updated Name' },
            headers: auth_header

      expect(response).to have_http_status(:not_found)
    end

    it 'does not allow POST requests' do
      post '/api/v1/members',
           params: { name: 'New Member' },
           headers: auth_header

      expect(response).to have_http_status(:not_found)
    end

    it 'does not allow DELETE requests' do
      delete "/api/v1/members/#{active_member.id}",
             headers: auth_header

      expect(response).to have_http_status(:not_found)
    end
  end
end
