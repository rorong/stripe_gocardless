Rails.application.routes.draw do
  devise_for :users
  # get 'home/index'
  root 'home#index'
  post '/create_subscription', to: 'home#create_subscription'
  get '/confirm_mandate' => 'home#confirm_mandate', as: 'confirm_mandate'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
