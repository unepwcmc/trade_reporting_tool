{div, a, span} = React.DOM

window.AnnualReportUploadsContainer = class AnnualReportUploadsContainer extends React.Component

  constructor: (props, context) ->
    super(props, context)
    @state = {
      pageName: props.pageName,
      totalPages: props.totalPages
      page: 1,
      sandboxEnabled: props.sandboxEnabled
    }
    @incrementPage = @changePage.bind(@, 1)
    @decrementPage = @changePage.bind(@, -1)

  render: ->
    div
      className: 'annual-report-uploads-list'
      React.createElement(AnnualReportUploads,
        {
          key: @state.pageName,
          pageName: @state.pageName,
          page: @state.page,
          sandboxEnabled: @state.sandboxEnabled
        }
      )
      @renderPaginator() if @state.totalPages > 1

  renderPaginator: ->
    div(
      { className: 'paginator' }
      a(
        {
          className: 'paginator-link',
          onClick: @decrementPage
        }
        '<< Previous'
      )
      span(
        {}
        "Page "
        span(
          { className: 'current-page' }
          span(
            {}
            @state.page
          )
        )
        span(
          {}
          " of " + @state.totalPages
        )
      )
      a(
        {
          className: 'paginator-link',
          onClick: @incrementPage
        }
        'Next >>'
      )
    )

  changePage: (page) ->
    @setState({page: @state.page + page})
