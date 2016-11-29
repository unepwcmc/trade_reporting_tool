{div, a, i, tr, td} = React.DOM
window.ShipmentVersion = class ShipmentVersion extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      shipment: props.shipment
      changes: props.changes
      rowType: props.rowType
    }

  render: ->
    data = @state.shipment
    tr({ className: @state.rowType },
      td({}
        div({}, data.updated_at)
        div({}, Object.keys(@state.changes).length + " changes")
      )
      td({}, data.appendix)
      td({},
        div(
          { className: 'bold' }
          data.taxon_name
        )
        div({}, data.taxon_name) # Replace with accepted_name
      )
      td({}, data.term)
      td({}, data.quantity)
      td({}, data.trading_partner)
      td({}, data.country_of_origin)
      td({}, data.import_permit)
      td({}, data.export_permit)
      td({}, data.origin_permit)
      td({}
        data.purpose_code + ' - ' + data.source_code + ' - ' + data.year
      )
    )
