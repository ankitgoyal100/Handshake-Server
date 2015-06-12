Rails.application.routes.draw do
  
  resources :tokens, :only => [:create, :destroy]

  get '/account', to: 'users#account'
  delete '/account', to: 'users#destroy'
  post '/account', to: 'users#create'
  put '/account', to: 'users#update'
  post '/account/location', to: 'users#update_location'

  devise_for :user, skip: [ :registrations, :sessions ], controllers: { passwords: 'passwords' }

  devise_scope :user do
    post 'password', to: 'passwords#create', as: :password_url
  end

  resources :cards, except: [:new, :edit, :destroy]
  
  get '/contacts', to: 'contacts#index'
  delete '/users/:id', to: 'contacts#destroy'
  
  get '/users/:id', to: 'users#show'
  get '/users/:id/contacts', to: 'users#contacts'
  get '/users/:id/mutual', to: 'users#mutual'
  
  get '/requests', to: 'requests#index'
  post '/users/:id/request', to: 'requests#create'
  delete '/users/:id/request', to: 'requests#destroy'
  
  post '/users/:id/accept', to: 'requests#accept'
  delete '/users/:id/decline', to: 'requests#decline'

  get '/groups', to: 'groups#index'
  get '/groups/:id', to: 'groups#show'
  get '/groups/:id/members', to: 'groups#members'
  post '/groups', to: 'groups#create'
  put '/groups/:id', to: 'groups#update'

  post '/groups/join', to: 'groups#join'
  delete '/groups/:id', to: 'groups#leave'

  get '/search', to: 'search#index'
  post '/search/suggestions', to: 'search#suggestions'

  get '/feed', to: 'feeds#index'

  root to: "static_pages#home"
  get '/terms', to: 'static_pages#terms'
   
end
