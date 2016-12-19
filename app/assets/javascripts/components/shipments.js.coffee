{tbody} = React.DOM
window.Shipments = class Shipments extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: [],
      pageName: props.pageName,
      page: props.page,
      annualReportUploadId: props.annualReportUploadId
      validationErrorId: props.validationErrorId
      changesHistory: props.changesHistory
      format: props.format
      userType: props.userType
    }

  render: ->
    tbody({},
      @getShipments()
    )

  componentDidMount: ->
    @getData()

  componentWillReceiveProps: (nextProps) ->
    @getData(nextProps)

  getShipments: ->
    return '' unless @state.data
    for shipment, idx in @state.data
      rowType = if idx % 2 == 0 then 'even' else 'odd'
      [
        React.createElement(Shipment,
          {
            key: shipment.id
            shipment: shipment
            rowType: rowType
            annualReportUploadId: @state.annualReportUploadId
            changesHistory: @state.changesHistory
          }
        )
        if @state.changesHistory
          for version, v_idx in shipment.versions
            React.createElement(ShipmentVersion,
              {
                key: "#{shipment.id}_#{v_idx}"
                shipment: version
                index: v_idx
                changes: shipment.changes[v_idx]
                rowType: rowType
                userType: @state.userType
              }
            )
      ]

  getData: (props) ->
    props = props || @props
    aru_id = @state.annualReportUploadId
    validation_error_id = @state.validationErrorId
    url = window.location.origin + "/api/v1/annual_report_uploads/#{aru_id}"
    if @state.changesHistory
      if @state.format == 'pdf'
        url = url + "/changes_history_download"
      else
        url = url + "/changes_history"
    else
      if validation_error_id
        url = url + "/validation_errors/#{validation_error_id}/shipments"
      else
        url = url + '/shipments'
    $.ajax({
      url: url
      data: props.pageName + "=" + props.page
      dataType: 'json'
      success: (response) =>
        @setState({data: response[props.pageName]})
      error: (response) ->
        console.log("Something went wrong")
    })
