{div, h1, h2, p, i, a} = React.DOM
window.AnnualReportUploads = class AnnualReportUploads extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: [],
      pageName: props.pageName,
      page: props.page,
      sandboxEnabled: props.sandboxEnabled
      adminUrl: props.adminUrl
    }

  render: ->
    uploads = @generateUploads()
    div
      className: 'annual-report-uploads'
      @generateUploads()

  componentDidMount: ->
    @getData()

  componentWillReceiveProps: (nextProps) ->
    @getData(nextProps)

  generateUploads: ->
    return '' unless @state.data
    for annualReportUpload in @state.data
      div(
        { className: 'annual-report-upload', key: annualReportUpload.id }
        React.createElement(AnnualReportUpload,
          {
            key: annualReportUpload.id,
            annualReportUpload: annualReportUpload,
            sandboxEnabled: @state.sandboxEnabled
            adminUrl: @state.adminUrl
          }
        )
      )

  getData: (props) ->
    props = props || @props
    $.ajax({
      url: window.location.origin + '/api/v1/annual_report_uploads'
      data: props.pageName + "=" + props.page
      dataType: 'json'
      success: (response) =>
        data = response.annual_report_uploads
        @setState({data: data[props.pageName]})
      error: (response) ->
        console.log("Something went wrong")
    })

