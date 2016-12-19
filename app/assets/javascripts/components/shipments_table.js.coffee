{div, table, thead, tbody, tr, th, td, span} = React.DOM
window.ShipmentsTable = class ShipmentsTable extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      pageName: props.pageName,
      totalPages: props.totalPages,
      page: 1,
      annualReportUploadId: props.annualReportUploadId
      validationErrorId: props.validationErrorId
      changesHistory: props.changesHistory
      format: props.format
    }
    @incrementPage = @changePage.bind(@, 1)
    @decrementPage = @changePage.bind(@, -1)
    @firstPage = @changePage.bind(@, 'first')
    @lastPage = @changePage.bind(@, 'last')

  render: ->
    div(
      {}
      table(
        { className: 'shipments-table' }
        @renderHead()
        @renderBody()
      )
      @renderPaginator() if @state.totalPages > 1
    )

  renderHead: ->
    thead({},
      tr({},
        if @state.changesHistory
          th({}
            div({}, 'Reference')
            div({ className: 'subtitle' }, 'Change time')
          )
        th({}, 'Appendix')
        th({},
          div({}, 'Taxon Name')
          div({ className: 'subtitle' }, 'Accepted Taxon Name')
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
          div({}, 'Year')
        )
        unless @state.changesHistory
          th({}, 'Actions')
        else
          [
            th({}, 'Updated at')
            th({}, 'Updated by')
          ]
      )
    )

  renderBody: ->
    React.createElement(Shipments,
      {
        key: @state.pageName
        pageName: @state.pageName
        page: @state.page
        annualReportUploadId: @state.annualReportUploadId
        validationErrorId: @state.validationErrorId
        changesHistory: @state.changesHistory
        format: @state.format
      }
    )

  renderPaginator: ->
    React.createElement(Paginator,
      {
        key: 'shipments_paginator'
        page: @state.page
        totalPages: @state.totalPages
        firstPage: @firstPage
        lastPage: @lastPage
        decrementPage: @decrementPage
        incrementPage: @incrementPage
      }
    )

  changePage: (page) ->
    if page == 'first'
      @setState({page: 1})
    else if page == 'last'
      @setState({page: @state.totalPages})
    else
      newPage = @state.page + page
      unless newPage < 1 || newPage > @state.totalPages
        @setState({page: @state.page + page})


