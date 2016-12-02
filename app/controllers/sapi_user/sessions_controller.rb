class SapiUser::SessionsController < ::Devise::SessionsController
  before_action :is_authorised?, only: [:create]

  def new
    @email = params[:user]
    @autofocus_email = !@email.present?
    super
  end

  def is_authorised?
    email = params[:sapi_user][:email]
    user = Sapi::User.find_by_email(email)
    if user && user.role != Sapi::User::MANAGER
      redirect_to new_sapi_user_session_path, flash: { alert: t('unauthorised') }
    end
  end
end
