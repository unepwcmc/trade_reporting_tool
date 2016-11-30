class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale
  helper_method :current_user, :destroy_user

  def after_sign_in_path_for(resource)
    sign_in_url = if resource.is_a?(Epix::User)
                    new_epix_user_session_url
                  else
                    new_sapi_user_session_url
                  end.split('?').first
    referer_index = if request.referer.index('?')
                      request.referer.index('?') - 1
                    else
                      request.referer.size
                    end
    if request.referer.slice(0..(referer_index)) == sign_in_url
      annual_report_uploads_path
    else
      stored_location_for(resource) || root_path
    end
  end

  def current_user
    current_epix_user || current_sapi_user
  end

  def destroy_user
    if current_epix_user
      destroy_epix_user_session_path
    elsif current_sapi_user
      destroy_sapi_user_session_path
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
