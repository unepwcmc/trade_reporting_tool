{div, a, i, span} = React.DOM
window.ValidationErrors = class ValidationErrors extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: @props.validationErrors
    }

  render: ->
    div(
      { className: 'validation-errors-box' }
      @renderHeader()
      @renderInfoBox()
      @renderValidationErrors()
    )

  renderHeader: ->
    div(
      { className: 'validation-errors-header border-btm' }
      span(
        { className: 'errors-count bold' }
        "Validation errors (#{@state.data.length})"
      )
      a(
        { className: 'toggle-errors button' }
        i({ className: 'fa fa-angle-up' })
      )
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



