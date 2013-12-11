Horsey::Application.routes.draw do
  root 'application#index'

  get 'horsey', to: 'application#horsey'
end
