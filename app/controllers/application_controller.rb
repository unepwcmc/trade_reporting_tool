class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
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

  def default_url_options
    { locale: I18n.locale }
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def authenticate_user!
    render "annual_report_uploads/unauthorised" unless (current_epix_user || current_sapi_user).present?
  end

  def authorise_edit
    aru_id = params[:annual_report_upload_id] || params[:id]
    aru = Trade::AnnualReportUpload.find(aru_id)
    creator = aru.creator
    authorised = true
    if !current_user
      authorised = false
    elsif creator.is_a?(Epix::User)
      if current_user.is_a?(Sapi::User)
        flash[:alert] = t('action_unauthorised')
        redirect_to (request.referer || root_path) and return true
      end
      authorised = (current_user.id == creator.id ||
        (current_user.organisation.id == creator.organisation.id && current_user.is_admin))
    else
      authorised = current_user.is_a?(Sapi::User) && current_user.role == Sapi::User::MANAGER
    end
    if !authorised || aru.submitted_at.present?
      flash[:alert] = t('action_unauthorised')
      redirect_to (request.referer || root_path)
    end
  end

  def paper_trail_enabled_for_controller
    !(is_a? ::Devise::SessionsController)
  end

  def user_for_paper_trail
    current_user.is_a?(Epix::User) ? "Epix:#{current_user.id}" : "Sapi:#{current_user.id}"
  end
end
