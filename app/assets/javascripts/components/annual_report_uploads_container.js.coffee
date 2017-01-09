{div, a, span} = React.DOM

window.AnnualReportUploadsContainer = class AnnualReportUploadsContainer extends React.Component

  constructor: (props, context) ->
    super(props, context)
    @state = {
      pageName: props.pageName,
      totalPages: props.totalPages
      page: 1,
      sandboxEnabled: props.sandboxEnabled
      adminUrl: props.adminUrl
      userType: props.userType

    }
    @incrementPage = @changePage.bind(@, 1)
    @decrementPage = @changePage.bind(@, -1)
    @firstPage = @changePage.bind(@, 'first')
    @lastPage = @changePage.bind(@, 'last')

  render: ->
    div(
      {
        id: @state.pageName,
        className: "annual-report-uploads-list"
      }
      React.createElement(AnnualReportUploads,
        {
          key: @state.pageName,
          pageName: @state.pageName,
          page: @state.page,
          sandboxEnabled: @state.sandboxEnabled
          adminUrl: @state.adminUrl
          userType: @state.userType
        }
      )
      @renderPaginator() if @state.totalPages > 1
    )

  renderPaginator: ->
    React.createElement(Paginator,
      {
        key: 'aru_paginator'
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
