class ChangesHistoryPdfGeneratorJob < ApplicationJob
  queue_as :default

  def perform(aru_id, cookie, domain, user, pages)
    rasterizer = Rails.root.join("vendor/assets/javascripts/rasterize.js")
    url = Rails.application.secrets.host
    url = url + "/annual_report_uploads/#{aru_id}/changes_history_pdf"
    dest_pdf = Rails.root.join("tmp/changes_history.pdf").to_s
    `phantomjs #{rasterizer} '#{url}' #{cookie} #{domain} #{pages}`

    NotificationMailer.changes_history_pdf(
      user, dest_pdf
    ).deliver
  end
end
