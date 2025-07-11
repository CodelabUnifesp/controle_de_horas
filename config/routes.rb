Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions'
             },
             skip: [:registrations]

  root 'pages#home'
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :users, only: [] do
        collection do
          get :my_user
          patch :update_my_user
        end
      end

      resources :members, only: %i[index show]

      resources :teams, only: %i[index show]

      resources :events, only: %i[index update create destroy show]

      # SUPER ADMIN SECTION
      namespace :super_admin do
        resources :reports, only: [] do
          collection do
            get :hours
          end
        end

        resources :members, only: %i[index update create show]
        resources :teams, only: %i[index update create destroy show]
      end
    end
  end

  match 'api/*unmatched', to: proc {
    [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
  }, via: :all

  get '*path', to: 'pages#home', constraints: ->(req) { !req.xhr? && req.format.html? }
end
