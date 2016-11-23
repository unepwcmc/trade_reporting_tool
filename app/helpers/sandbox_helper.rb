module SandboxHelper
  def download_and_submit
    content_tag(:div, nil, class: 'download-and-submit') do
      content_tag(:div, nil, class: 'download-report') do
        content_tag(:i, nil, class: 'fa fa-download') +
        link_to("Download report on existing errors", '#', class: 'bold')
      end +
      content_tag(:div, nil, class: 'submit-shipments') do
        validation_errors = @annual_report_upload.validation_errors
        submit_enabled = validation_errors.first.try(:is_primary).nil?
        link = submit_enabled ? '#submit_link' : ''
        enabled_class = submit_enabled ? 'submit-enabled' : 'submit-disabled'
        link_to("Submit shipments", link, class: "submit-aru button #{enabled_class}")
      end
    end
  end
end