Cloudamp::Application.routes.draw do
  match 'sessions/connect' => 'sessions#connect', :via => :get,    :as => 'connect_session'
  match 'sessions/new'     => 'sessions#new',     :via => :get,    :as => 'new_session'
  match 'sessions'         => 'sessions#destroy', :via => :delete, :as => 'session'
  
  match 'player'           => 'player#main',      :via => :get,    :as => 'main_player'
  
  root :to => 'welcome#index'
end
