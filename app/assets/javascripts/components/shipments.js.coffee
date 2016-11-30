{tbody} = React.DOM
window.Shipments = class Shipments extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: [],
      pageName: props.pageName,
      page: props.page,
      annualReportUploadId: props.annualReportUploadId
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
            changesHistory: !!@state.annualReportUploadId
          }
        )
        if @state.annualReportUploadId
          for version, v_idx in shipment.versions
            React.createElement(ShipmentVersion,
              {
                key: "#{shipment.id}_#{v_idx}"
                shipment: version
                changes: shipment.changes[v_idx]
                rowType: rowType
              }
            )
      ]

  getData: (props) ->
    props = props || @props
    url = window.location.origin
    aru_id = @state.annualReportUploadId
    if aru_id
      url = url + "/api/v1/annual_report_uploads/#{aru_id}/changes_history"
    else
      url = url + '/api/v1/shipments'
    $.ajax({
      url: url
      data: props.pageName + "=" + props.page
      dataType: 'json'
      success: (response) =>
        @setState({data: response[props.pageName]})
      error: (response) ->
        console.log("Something went wrong")
    })
