class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    sign_in_url = if resource.is_a?(Epix::User)
                    new_epix_user_session_url
                  else
                    new_sapi_user_session_url
                  end
    if request.referer.slice(0..(request.referer.index('?')-1)) == sign_in_url
      annual_report_uploads_path
    else
      stored_location_for(resource) || request.referer || root_path
    end
  end
end
