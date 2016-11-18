module ApplicationHelper
  def home_path
    home =
      case Rails.env
      when 'staging'
        if current_sapi_user
          Rails.application.secrets.sapi_staging_path
        elsif current_epix_user
          Rails.application.secrets.epix_staging_path
        end
      when 'production'
        if current_sapi_user
          Rails.application.secrets.sapi_production_path
        elsif current_epix_user
          Rails.application.secrets.epix_production_path
        end
      else
        '/'
      end
    link_to t('home'), home
  end
end
