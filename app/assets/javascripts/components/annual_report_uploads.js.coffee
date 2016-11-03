{div, h1, h2, p, i} = React.DOM
window.AnnualReportUploads = class AnnualReportUploads extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = { annualReportUploads: props.data }

  render: ->
    uploads = @generateUploads()
    div
      className: 'annual-report-uploads'
      @generateUploads()


  generateUploads: ->
    for annualReportUpload in @state.annualReportUploads
      div(
        {key: annualReportUpload.id}
        React.createElement(AnnualReportUpload, {key: annualReportUpload.id, annualReportUpload: annualReportUpload})
      )

