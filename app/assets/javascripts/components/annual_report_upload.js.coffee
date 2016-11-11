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
          @renderWithSandbox()
        a(
          {className: 'delete-upload', href: '#'}
          i({className: 'fa fa-times'})
          "Delete"
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

  renderWithSandbox: ->
    a(
      { className: 'upload-summary', href: '#sandbox' }
      @summary()
    )

  summary: ->
    upload = @state.annualReportUpload
    upload.trading_country + ' (' + upload.point_of_view + '), ' +
      upload.number_of_rows + ' shipments' + ' uploaded on ' +
      upload.created_at + ' by ' + upload.created_by + ' (' +
      upload.file_name + ')'

  displaySubmissions: ->
    i(
      {className: 'submission-details'}
      span(
        {className: 'bold'}
        @state.annualReportUpload.number_of_rows_submitted
      )
      ' records submitted by '
      span(
        {className: 'bold'}
        @state.annualReportUpload.submitted_by
      )
      ' the '
      span(
        {className: 'bold'}
        @state.annualReportUpload.submitted_at
      )
    )
