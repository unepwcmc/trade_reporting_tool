class EpixUser::SessionsController < Devise::SessionsController
  def new
    @email = params[:user]
    @autofocus_email = !@email.present?
    super
  end
end
