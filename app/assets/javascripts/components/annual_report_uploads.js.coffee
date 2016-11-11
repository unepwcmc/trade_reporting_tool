{div, h1, h2, p, i} = React.DOM
window.AnnualReportUploads = class AnnualReportUploads extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = { annualReportUploads: props.data, sandbox_enabled: props.sandbox_enabled }

  render: ->
    uploads = @generateUploads()
    div
      className: 'annual-report-uploads'
      @generateUploads()


  generateUploads: ->
    for annualReportUpload in @state.annualReportUploads
      div(
        { className: 'annual-report-upload', key: annualReportUpload.id }
        React.createElement(AnnualReportUpload,
          {
            key: annualReportUpload.id,
            annualReportUpload: annualReportUpload,
            sandbox_enabled: @state.sanndbox_enabled
          }
        )
      )

