{div, table, thead, tbody, tr, th, td, span} = React.DOM
window.ShipmentsTable = class ShipmentsTable extends React.Component
  constructor: (props, context) ->
    super(props, context)

  render: ->
    table(
      { className: 'shipments-table' }
      @renderHead()
      @renderBody()
    )

  renderHead: ->
    thead({},
      tr({},
        th({}, 'Appendix')
        th({},
          div({}, 'Taxon Name')
          div({ className: 'accepted-name' }, 'Accepted Taxon Name')
        )
        th({}, 'Term')
        th({}, 'Qty')
        th({},
          div({}, 'Trading')
          div({}, 'Partner')
        )
        th({}, 'Origin')
        th({ className: 'permit-th' },
          div({ className: 'empty-col permit-col border-btm' }, '')
          div({ className: 'permit-col-name' }, 'Import')
        )
        th({ className: 'permit-th' },
          div({ className: 'permit-col border-btm', colSpan: 3 }, 'Permit')
          div({ className: 'permit-col-name' }, 'Export')
        )
        th({ className: 'permit-th' },
          div({ className: 'empty-col permit-col border-btm' }, '')
          div({ className: 'permit-col-name' }, 'Origin')
        )
        th({},
          div({}, 'Purpose-')
          div({}, 'Source-')
          div({}, 'Year-')
        )
        th({}, 'Actions')
      )
    )

  renderBody: ->
    tbody({},
      tr({},
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
        td({}, 1)
      )
    )
