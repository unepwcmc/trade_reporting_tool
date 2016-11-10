{div, p, a, h1, h2} = React.DOM
window.AnnualReportUpload = class AnnualReportUpload extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = { annualReportUpload: props.annualReportUpload }
    @changeFile = @updateModal.bind(@, props.annualReportUpload.id)

  updateModal: (filename) ->
    $('#download_modal .file-to-download').html(filename)

  render: ->
    unless @props.sandbox_enabled
      a(
        {
          href: '#',
          "data-toggle": "modal",
          "data-target": "#download_modal",
          onClick: @changeFile,
        }
        @state.annualReportUpload.id
      )
