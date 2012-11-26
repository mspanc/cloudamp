Cloudamp::Application.routes.draw do
  resources :playlists, :defaults => { :format => 'json' }, :only => [ :create, :update, :destroy ] do
    member do
      post :track_positions
    end
  end
  resources :tracks,    :defaults => { :format => 'json' }, :only => [ :create, :update, :destroy ]
  
  match 'sessions/connect' => 'sessions#connect', :via => :get,    :as => 'connect_session'
  match 'sessions/new'     => 'sessions#new',     :via => :get,    :as => 'new_session'
  match 'sessions'         => 'sessions#destroy', :via => :delete, :as => 'session'
  
  match 'player'           => 'player#main',      :via => :get,    :as => 'main_player'
  match 'bookmarklet/add'  => 'bookmarklet#add',  :via => :get,    :as => 'add_bookmarklet'

  root :to => 'welcome#index'
end
