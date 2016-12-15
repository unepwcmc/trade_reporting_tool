require 'zip'
class ChangesHistoryPdfGeneratorJob < ApplicationJob
  queue_as :default

  def perform(aru_id, cookie, domain, user, pages)
    rasterizer = Rails.root.join("vendor/assets/javascripts/rasterize.js")
    url = Rails.application.secrets.host
    url = url + "/annual_report_uploads/#{aru_id}/changes_history_pdf"
    dir = Rails.root.join("tmp/").to_s
    `phantomjs #{rasterizer} '#{url}' #{cookie} #{domain} #{pages} #{dir}`

    zipfile = "#{dir}changes_history_for_aru_#{aru_id}.zip"
    Zip::File.open(zipfile, Zip::File::CREATE) do |zipfile|
      (1..pages).each do |index|
        filename = "changes_history_#{index}.pdf"
        zipfile.add(filename, dir + filename)
      end
    end

    NotificationMailer.changes_history_pdf(user, zipfile).deliver
  end
end
