class SapiUser::SessionsController < ::Devise::SessionsController
  def new
    @email = params[:user]
    super
  end
end
