Rails.application.routes.draw do
  namespace :sapi do
    devise_for :users, {
      controllers: {
        sessions: 'sapi_user/sessions'
      },
      class_name: Sapi::User
    }

  end

  namespace :epix do
    devise_for :users, {
      controllers: {
        sessions: 'epix_user/sessions'
      },
      class_name: Epix::User
    }
  end

  resources :annual_report_uploads, only: [:index]

  wash_out "api/v1/cites_reporting"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
