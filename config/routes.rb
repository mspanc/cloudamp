Cloudamp::Application.routes.draw do
  match 'authentication/redirect'           => 'authentication#redirect',           :via => :get, :as => 'redirect_authentication'
  match 'authentication/initialize_session' => 'authentication#initialize_session', :via => :get, :as => 'initialize_session_authentication'
  
  match 'player'                            => 'player#main',                       :via => :get, :as => 'main_player'
  
  root :to => 'welcome#index'
end
