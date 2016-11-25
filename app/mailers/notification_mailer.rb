class NotificationMailer < ApplicationMailer

  def validation_result(user, aru, validation_report)
    @user = user
    @aru = aru
    @validation_report = validation_report

    mail(to: @user.email, subject: 'CITES Report validation result')
  end

end
