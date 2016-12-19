class ChangesHistoryGeneratorJob < ApplicationJob
  queue_as :default

  def perform(aru_id, cookie, domain, user, pages) # TODO
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      message = "CITES Report #{aru_id} not found"
      Rails.logger.warn message
      Appsignal.add_exception(e) if defined? Appsignal
      NotificationMailer.changelog_failed(user, aru).deliver
    end

    tempfile = ChangelogCsvGenerator.call(aru, user)

    NotificationMailer.changelog(user, aru, tempfile).deliver # TODO
  end
end
