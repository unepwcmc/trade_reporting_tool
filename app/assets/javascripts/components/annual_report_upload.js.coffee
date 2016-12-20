{div, p, a, h1, h2, i, span} = React.DOM
window.AnnualReportUpload = class AnnualReportUpload extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      annualReportUpload: props.annualReportUpload
      submitted: !!props.annualReportUpload.submitted_at
      sandboxEnabled: !!props.sandboxEnabled
      adminUrl: props.adminUrl
    }
    @updateModal = @updateModal.bind(@, @summary())

  updateModal: (filename) ->
    $('#download_modal .file-to-download').html(filename)
    download_button = $('#download_modal .download-button')
    modal_content = $('#download_modal .modal-content')
    info_text = $('#download_modal .info-text')
    download_button.attr('href',
      "/annual_report_uploads/#{@state.annualReportUpload.id}/download_error_report"
    )
    if @state.annualReportUpload.has_validation_report
      download_button.removeClass('disabled')
    else
      download_button.addClass('disabled')
    if @state.submitted
      modal_content.addClass('smaller')
      text = I18n.t('submitted_at_info_box') + " #{@state.annualReportUpload.submitted_by} "
      text = text + I18n.t('the') + " #{@state.annualReportUpload.submitted_at}"
      info_text.html(text)
    else
      modal_content.removeClass('smaller')
      text = I18n.t('change_sandbox_settings')
      text = text + "<a href='#{@state.adminUrl}' class='bold'>#{I18n.t('your_admin_page')}</a>"
      info_text.html(text)

  render: ->
    if @state.submitted
      div(
        {className: 'past-upload'}
        @renderWithDownload()
        @displaySubmissions()
      )
    else
      div(
        {className: 'in-progress-upload'}
        unless @state.sandboxEnabled
          @renderWithDownload()
        else
          @renderWithSandbox(@state.annualReportUpload)
        a(
          {
            className: 'delete-upload',
            href: "/annual_report_uploads/#{@state.annualReportUpload.id}",
            "data-method": 'delete'
            "data-confirm": 'Are you sure you want to delete this report?'
          }
          i({className: 'fa fa-times'})
          I18n.t('delete')
        )
      )

  renderWithDownload: ->
    a(
      {
        className: 'upload-summary',
        href: '#',
        "data-toggle": "modal",
        "data-target": "#download_modal",
        onClick: @updateModal,
      }
      @summary()
    )

  renderWithSandbox: (aru) ->
    a(
      {
        className: 'upload-summary',
        href: "annual_report_uploads/#{aru.id}?locale=#{I18n.locale}"
      }
      @summary()
    )

  summary: ->
    upload = @state.annualReportUpload
    upload.trading_country + ' (' + upload.point_of_view + '), ' +
      upload.number_of_rows + " #{I18n.t('shipments')} " + " #{I18n.t('uploaded_on')} " +
      upload.created_at + " #{I18n.t('by')} " + upload.created_by + ' (' +
      upload.file_name + ')'

  displaySubmissions: ->
    i(
      {className: 'submission-details'}
      span(
        {className: 'bold'}
        @state.annualReportUpload.number_of_rows_submitted
      )
      " #{I18n.t('records_submitted_by')} "
      span(
        {className: 'bold'}
        @state.annualReportUpload.submitted_by
      )
      " #{I18n.t('the')} "
      span(
        {className: 'bold'}
        @state.annualReportUpload.submitted_at
      )
    )
