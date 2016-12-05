{div, a, i, span} = React.DOM
window.ValidationErrors = class ValidationErrors extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: props.validationErrors,
      numToShow: 5
      showAllErrors: false
      hideAll: false
      ignored: props.ignored
    }
    @toggleBox = @toggleBox.bind(@)
    @showMoreErrors = @showMore.bind(@)
    @showLessErrors = @showLess.bind(@)

  render: ->
    div(
      { className: 'validation-errors-box' }
      @renderHeader()
      @renderBody()
    )

  renderHeader: ->
    borderBottom = if @state.hideAll then '' else 'border-btm'
    errors = if @state.ignored then I18n.t('ignored_validation_errors') else I18n.t('validation_errors')
    div(
      { className: "validation-errors-header #{borderBottom}" }
      span(
        { className: 'errors-count bold' }
        "#{errors} (#{@state.data.length})"
      )
      a(
        {
          className: 'toggle-errors button'
          onClick: @toggleBox
        }
        if @state.hideAll
          i({ className: 'fa fa-angle-down' })
        else
          i({ className: 'fa fa-angle-up'})
      )
    )

  renderBody: ->
    div(
      { className: 'validation-errors-body' }
      unless @state.hideAll
        [
          @renderInfoBox()
          @renderValidationErrors()
          if @state.data.length > @state.numToShow
            if @state.showAllErrors then @renderShowLess() else @renderShowMore()
        ]
    )

  renderInfoBox: ->
    div(
      { className: 'info-box validation-errors-info' }
      i({ className: 'fa fa-info-circle' })
      span(
        {}
        I18n.t('errors_info')
      )
    )

  renderValidationErrors: ->
    for validationError, idx in @state.data
      hidden = if @state.showAllErrors then false else idx >= @state.numToShow
      unless hidden
        React.createElement(ValidationError,
          {
            key: validationError.id
            data: validationError
          }
        )

  renderShowMore: ->
    span(
      {
        className: 'show-more'
        onClick: @showMoreErrors
      }
      i({ className: 'fa fa-plus-circle' })
      I18n.t('show_more_errors')
    )

  renderShowLess: ->
    span(
      {
        className: 'show-more'
        onClick: @showLessErrors
      }
      i({ className: 'fa fa-minus-circle' })
      I18n.t('show_less_errors')
    )


  toggleBox: ->
    @setState({ hideAll: !@state.hideAll})

  showMore: ->
    @setState({ showAllErrors: true })

  showLess: ->
    @setState({ showAllErrors: false })

