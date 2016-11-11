module AnnualReportUploadHelper
  def report_radio_buttons
    label_tag(:export_report_, {}) do
      radio_button_tag(:export_report, nil, true, {
        name: 'point_of_view'
      }) +
      content_tag(:span, t('export_report'))
    end +
    label_tag(:import_report_, {}) do
      radio_button_tag(:import_report, nil, false, {
        name: 'point_of_view'
      }) +
      content_tag(:span, t('import_report'))
    end
  end
end
