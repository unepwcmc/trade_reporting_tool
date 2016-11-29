{div, a, i, tr, td, span} = React.DOM
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
    keys = Object.keys(@state.changes)
    tr({ className: @state.rowType },
      td({}
        div({}, data.updated_at)
        div({}, keys.length + " changes")
      )
      td({}, span({ className: 'appendix' }, data.appendix))
      td({},
        div(
          { className: 'taxon_name bold' }
          data.taxon_name
        )
        div({ className: 'accepted-name' }, data.taxon_name) # Replace with accepted_name
      )
      td({}, span({ className: 'term' }, data.term))
      td({}, span({ className: 'quantity' }, data.quantity))
      td({}, span({ className: 'trading_partner' }, data.trading_partner))
      td({}, span({ className: 'country_of_origin' }, data.country_of_origin))
      td({}, span({ className: 'import_permit' }, data.import_permit))
      td({}, span({ className: 'export_permit' }, data.export_permit))
      td({}, span({ className: 'origin_permit' }, data.origin_permit))
      td({}
        span({ className: 'purpose_code'}, data.purpose_code)
        ' - '
        span({ className: 'source_code' }, data.source_code)
        ' - '
        span({ className: 'year' }, + data.year)
      )
    )

  componentDidMount: ->
    keys = Object.keys(@state.changes)
    for key in keys
      regex = new RegExp(".*#{key}.*")
      $('td span').filter( ->
        if $(@).attr('class') && $(@).attr('class').match(regex)
          $(@).addClass('changed')
      )
