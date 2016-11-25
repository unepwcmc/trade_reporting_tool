class NotificationMailer < ApplicationMailer

  def validation_result(user, aru, validation_report, validation_report_csv_file)
    @user = user
    @aru = aru
    @status = validation_report[:CITESReportResult][:Status]
    @message = validation_report[:CITESReportResult][:Message]
    @has_errors = @aru.validation_report.present?
    if @has_errors
      attachments["validation_report_#{@aru.id}.csv"] = File.read(validation_report_csv_file.path)
    end
    mail(to: @user.email, subject: 'CITES Report validation result')
  end

end
