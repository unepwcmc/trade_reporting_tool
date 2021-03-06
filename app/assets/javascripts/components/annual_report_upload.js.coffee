{div, p, a, h1, h2, i, span} = React.DOM
window.AnnualReportUpload = class AnnualReportUpload extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      annualReportUpload: props.annualReportUpload
      submitted: !!props.annualReportUpload.submitted_at
      sandboxEnabled: !!props.sandboxEnabled
      adminUrl: props.adminUrl
      userType: props.userType
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
    download_button.find('i.download-spinner').show()
    if @state.annualReportUpload.has_validation_report
      download_button.removeClass('disabled')
    else
      download_button.addClass('disabled')
    if @state.submitted
      @isDownloadAvailable(download_button)
      text = I18n.t('submitted_at_info_box') + " " + @getSubmitter()
      text = text + " " + I18n.t('on') + " #{@state.annualReportUpload.submitted_at}. "
      text = text + I18n.t('download_info_box')
      info_text.html(text)
    else
      text = I18n.t('change_sandbox_settings')
      text = text + "<a href='#{@state.adminUrl}' class='bold'>#{I18n.t('your_admin_page')}</a>"
      info_text.html(text)

  isDownloadAvailable: (download_button) ->
    $.ajax({
      url: "/annual_report_uploads/#{@state.annualReportUpload.id}/download_available"
      dataType: 'json'
      success: (response) ->
        if response.available
          download_button.removeClass('disabled')
        download_button.find('i.download-spinner').hide()
      error: (response) ->
        console.log("Something went wrong while checking download availability")
    })

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
        if @state.userType == 'sapi' || @state.sandboxEnabled
          @renderWithSandbox(@state.annualReportUpload)
        else
          @renderWithDownload()
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
    upload_type = ''
    if upload.is_from_web_service
      upload_type = ' (via web service upload)'
    else
      upload_type = " via CSV upload "
      upload_type = upload_type + " (#{upload.file_name})" unless @state.submitted
    upload.trading_country + ' (' + upload.point_of_view + '), ' +
      upload.number_of_rows + " #{I18n.t('shipments')} " + " #{I18n.t('uploaded_on')} " +
      upload.created_at + " #{I18n.t('by')} " + upload.created_by + upload_type

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
        @getSubmitter()
      )
      " #{I18n.t('the')} "
      span(
        {className: 'bold'}
        @state.annualReportUpload.submitted_at
      )
    )

  getSubmitter: ->
    submitted_by_type = @state.annualReportUpload.submitted_by_type
    if @state.userType == 'sapi' || (@state.userType == submitted_by_type)
      @state.annualReportUpload.submitted_by
    else
      'WCMC'
