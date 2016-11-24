{tbody} = React.DOM
window.Shipments = class Shipments extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: [],
      pageName: props.pageName,
      page: props.page
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
      React.createElement(Shipment,
        {
          key: shipment.id
          shipment: shipment
          rowType: if idx % 2 == 0 then 'even' else 'odd'
        }
      )

  getData: (props) ->
    props = props || @props
    $.ajax({
      url: window.location.origin + '/api/v1/shipments'
      data: props.pageName + "=" + props.page
      dataType: 'json'
      success: (response) =>
        @setState({data: response[props.pageName]})
      error: (response) ->
        console.log("Something went wrong")
    })
