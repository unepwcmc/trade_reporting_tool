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

  get 'annual_report_uploads/:id/changes_history', to: 'annual_report_uploads#changes_history', as: 'changes_history'
  resources :annual_report_uploads, only: [:index, :show, :destroy] do
    resources :shipments, only: [:index, :destroy]
  end

  wash_out "api/v1/cites_reporting"

  namespace :api do
    namespace :v1 do
      get 'annual_report_uploads/:id/changes_history', to: 'annual_report_uploads#changes_history'
      resources :annual_report_uploads, only: [:index] do
        resources :shipments, only: [:index]
      end
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: redirect('/annual_report_uploads')
end
