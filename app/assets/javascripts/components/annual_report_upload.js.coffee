{div, p, a, h1, h2, i, span} = React.DOM
window.AnnualReportUpload = class AnnualReportUpload extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      annualReportUpload: props.annualReportUpload
      submitted: !!props.annualReportUpload.submitted_at
    }
    @changeFile = @updateModal.bind(@, @summary())

  updateModal: (filename) ->
    $('#download_modal .file-to-download').html(filename)

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
        unless @state.sandbox_enabled
          @renderWithDownload()
        else
          @renderWithSandbox(@state.annualReportUpload)
        a(
          {className: 'delete-upload', href: '#'}
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
        onClick: @changeFile,
      }
      @summary()
    )

  renderWithSandbox: (aru) ->
    a(
      {
        className: 'upload-summary',
        href: "annual_report_uploads/#{aru.id} "
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
