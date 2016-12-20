module ApplicationHelper

  def logo_image_tag
    if current_sapi_user
      image_tag("trt_logo_blue.jpg")
    else
      image_tag("epix_white_logo.png")
    end
  end

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

  def destroy_user_session_path
    if current_sapi_user
      destroy_sapi_user_session_path
    elsif current_epix_user
      destroy_epix_user_session_path
    else
      ''
    end
  end
end
