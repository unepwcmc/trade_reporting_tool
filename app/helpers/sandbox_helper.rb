module SandboxHelper
  def download_and_submit
    content_tag(:div, nil, class: 'download-and-submit') do
      content_tag(:div, nil, class: 'download-report') do
        content_tag(:i, nil, class: 'fa fa-download') +
        link_to("Download report on existing errors", '#', class: 'bold')
      end +
      content_tag(:div, nil, class: 'submit-shipments') do
        submit_enabled = @annual_report_upload.primary_validation_errors.empty?
        link = submit_enabled ? '#submit_link' : ''
        link_to("Submit shipments", link, class: 'button')
      end
    end
  end
end
