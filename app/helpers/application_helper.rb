module ApplicationHelper

  def home_link
    home_url = if current_sapi_user
                Rails.application.secrets.trade_admin_url
              elsif current_epix_user
                Rails.application.secrets.epix_url
              end
    if current_epix_user
      link_to t('back_to_epix'), home_url
    else
      link_to t('back_to_speciesplus'), home_url
    end
  end
end
