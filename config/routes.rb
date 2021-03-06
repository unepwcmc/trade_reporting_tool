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

  get 'annual_report_uploads/:id/changes_history',
    to: 'annual_report_uploads#changes_history', as: 'changes_history'
  get 'annual_report_uploads/:id/changes_history_download',
    to: 'annual_report_uploads#changes_history_download', as: 'changes_history_download'
  get 'annual_report_uploads/:id/download_error_report',
    to: 'annual_report_uploads#download_error_report', as: 'download_error_report'
  get 'annual_report_uploads/:id/download_available',
    to: 'annual_report_uploads#download_available', as: 'download_available'
  post 'annual_report_uploads/:id/submit', to: 'annual_report_uploads#submit', as: 'submit'
  resources :annual_report_uploads, only: [:index, :show, :destroy] do
    resources :shipments, only: [:index, :edit, :update, :destroy]
    get 'validation_errors/:validation_error_id/shipments', to: 'shipments#index', as: 'shipments_with_errors'
  end

  wash_out "api/v1/cites_reporting"

  namespace :api do
    namespace :v1 do
      get 'annual_report_uploads/:id/changes_history', to: 'annual_report_uploads#changes_history'
      get 'annual_report_uploads/:id/changes_history_download',
        to: 'annual_report_uploads#changes_history_download', as: 'changes_history_download'
      resources :annual_report_uploads, only: [:index] do
        resources :shipments, only: [:index]
        get 'validation_errors/:validation_error_id/shipments', to: 'shipments#index', as: 'shipment_with_errors'
      end
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: redirect('/annual_report_uploads')
end
