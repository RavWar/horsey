Horsey::Application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    root 'application#game'

    post 'mail', to: 'application#send_mail'
    get 'mail', to: 'application#mail'

    post 'save', to: 'application#save_score'
    post 'place', to: 'application#get_place'
  end
end
