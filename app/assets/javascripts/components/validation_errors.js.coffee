{div, a, i, span} = React.DOM
window.ValidationErrors = class ValidationErrors extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: @props.validationErrors,
      numToShow: 5
      showAll: false
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
    div(
      { className: 'validation-errors-header border-btm' }
      span(
        { className: 'errors-count bold' }
        "Validation errors (#{@state.data.length})"
      )
      a(
        {
          className: 'toggle-errors button'
          onClick: @toggleBox
        }
        i({ className: 'fa fa-angle-up' })
      )
    )

  renderBody: ->
    div(
      { className: 'validation-errors-body' }
      @renderInfoBox()
      @renderValidationErrors()
      if @state.showAll then @renderShowLess() else @renderShowMore()
    )

  renderInfoBox: ->
    div(
      { className: 'info-box' }
      i({ className: 'fa fa-info-circle' })
      span(
        {}
        "Once all primary errors corrected, you may have to correct secondary errors."
      )
    )

  renderValidationErrors: ->
    for validationError, idx in @state.data
      hidden = if @state.showAll then false else idx >= @state.numToShow
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
      "Show more errors"
    )

  renderShowLess: ->
    span(
      {
        className: 'show-more'
        onClick: @showLessErrors
      }
      i({ className: 'fa fa-minus-circle' })
      "Show less errors"
    )


  toggleBox: ->
    $('.validation-errors-body').slideToggle();
    $('.validation-errors-header').toggleClass('border-btm')
    $('.toggle-errors').find('i').toggleClass('fa-angle-up')
    $('.toggle-errors').find('i').toggleClass('fa-angle-down')

  showMore: ->
    @setState({ showAll: true })

  showLess: ->
    @setState({ showAll: false })

