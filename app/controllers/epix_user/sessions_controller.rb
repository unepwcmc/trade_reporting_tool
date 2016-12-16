class EpixUser::SessionsController < Devise::SessionsController
  before_action :is_authorised?, only: [:create]

  def new
    @email = params[:user]
    @autofocus_email = !@email.present?
    super
  end

  private

  def is_authorised?
    email = params[:epix_user][:email]
    user = Epix::User.find_by_email(email)
    authorised_organisations = Epix::Organisation::AUTHORISED
    if user && !(authorised_organisations.include? user.organisation.role)
      redirect_to new_epix_user_session_path, flash: { alert: t('unauthorised') }
    end
  end
end
