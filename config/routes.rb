Rails.application.routes.draw do
  root to: "dashboards#index"
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  get '/refresh_page', to: 'dashboards#refresh_page'
end
