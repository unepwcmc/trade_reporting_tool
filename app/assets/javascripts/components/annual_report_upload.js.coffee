{p} = React.DOM
window.AnnualReportUpload = class AnnualReportUpload extends React.Component
  render: ->
    p(
      {}
      @props.annualReportUpload.file_name
    )

