{div, a, span} = React.DOM
window.Paginator = class Paginator extends React.Component
  constructor: (props, context) ->
    super(props, context)

  render: ->
    div(
      { className: 'paginator' }
      a(
        {
          className: 'paginator-link',
          onClick: @props.firstPage
        }
        "|< #{I18n.t('first')}"
      )
      a(
        {
          className: 'paginator-link',
          onClick: @props.decrementPage
        }
        "<< #{I18n.t('previous')}"
      )
      span(
        {}
        "#{I18n.t('page')} "
        span(
          { className: 'current-page' }
          span(
            {}
            @props.page
          )
        )
        span(
          {}
          " #{I18n.t('of')} " + @props.totalPages
        )
      )
      a(
        {
          className: 'paginator-link',
          onClick: @props.incrementPage
        }
        "#{I18n.t('next')} >>"
      )
      a(
        {
          className: 'paginator-link',
          onClick: @props.lastPage
        }
        "#{I18n.t('last')} >|"
      )
    )
