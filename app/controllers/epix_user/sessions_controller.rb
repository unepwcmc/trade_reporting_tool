class EpixUser::SessionsController < Devise::SessionsController
  def new
    @email = params[:user]
    super
  end
end
