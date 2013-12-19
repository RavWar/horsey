Horsey::Application.routes.draw do
  root 'application#index'

  get 'horsey', to: 'application#horsey'

  post 'mail', to: 'application#send_mail'
  get 'mail', to: 'application#mail'
end
