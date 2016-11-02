class SapiUser::SessionsController < ::Devise::SessionsController
  def new
    @email = params[:user]
    @autofocus_email = !@email.present?
    @autofocus_password = !@autofocus_email
    super
  end
end
