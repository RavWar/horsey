Horsey::Application.routes.draw do
  root 'application#index'

  get 'horsey', to: 'application#game'

  post 'mail', to: 'application#send_mail'
  get 'mail', to: 'application#mail'

  post 'save', to: 'application#save_score'
  post 'place', to: 'application#get_place'
end
