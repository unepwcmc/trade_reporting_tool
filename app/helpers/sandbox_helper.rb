module SandboxHelper
  def download_and_submit
    download_disabled =
      @annual_report_upload.has_validation_report ? '' : 'disabled'
    content_tag(:div, nil, class: 'download-and-submit') do
      content_tag(:div, nil, class: "download-report #{download_disabled}") do
        content_tag(:i, nil, class: 'fa fa-download') +
        link_to(t('download_report_on_errors'), download_error_report_path, class: 'bold')
      end +
      content_tag(:div, nil, class: 'submit-shipments') do
        validation_errors = @annual_report_upload.validation_errors
        submit_enabled = validation_errors.first.try(:is_primary).nil?
        link = submit_enabled ? '#submit_link' : ''
        enabled_class = submit_enabled ? 'submit-enabled' : 'submit-disabled'
        link_to(t('submit_shipments'), link, class: "submit-aru button #{enabled_class}")
      end
    end
  end
end
