{div, a, i, span} = React.DOM
window.ValidationErrors = class ValidationErrors extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: @props.validationErrors
    }
    @toggleBox = @toggleBox.bind(@)

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
    for validationError in @state.data
      React.createElement(ValidationError,
        {
          key: validationError.id
          data: validationError
        }
      )

  toggleBox: ->
    $('.validation-errors-body').slideToggle();
    $('.validation-errors-header').toggleClass('border-btm');
    $('.toggle-errors').find('i').toggleClass('fa-angle-up')
    $('.toggle-errors').find('i').toggleClass('fa-angle-down')


