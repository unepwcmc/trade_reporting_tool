{div, p, a, h1, h2} = React.DOM
window.AnnualReportUpload = class AnnualReportUpload extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      annualReportUpload: props.annualReportUpload
      submitted: !!props.annualReportUpload.submitted_at
    }
    @changeFile = @updateModal.bind(@, props.annualReportUpload.id)

  updateModal: (filename) ->
    $('#download_modal .file-to-download').html(filename)

  render: ->
    if @state.submitted
      @renderWithDownload()
    else
      unless @state.sandbox_enabled
        @renderWithDownload()
      else
        @renderWithSandbox()

  renderWithDownload: ->
    a(
      {
        href: '#',
        "data-toggle": "modal",
        "data-target": "#download_modal",
        onClick: @changeFile,
      }
      @state.annualReportUpload.id
    )

  renderWithSandbox: ->
    a(
      {href: '#sandbox'}
      @state.annualReportUpload.id
    )
