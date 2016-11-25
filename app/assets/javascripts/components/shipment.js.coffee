{div, a, i, tr, td} = React.DOM
window.Shipment = class Shipment extends React.Component
  constructor: (props, context) ->
    super(props, context)

  render: ->
    data = @props.shipment
    tr({ className: @props.rowType},
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
      td({ className: 'actions-col' },
        div(
          {}
          a(
            { className: 'green-link-underlined' }
            i({ className: 'fa fa-pencil-square-o'})
            " #{I18n.t('edit')}"
          )
        )
        div(
          {}
          a(
            { className: 'green-link-underlined' }
            i({ className: 'fa fa-times' })
            " #{I18n.t('delete')}"
          )
        )
      )
    )
