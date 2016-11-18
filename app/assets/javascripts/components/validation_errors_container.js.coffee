{div, a, span} = React.DOM

window.ValidationErrorsContainer = class ValidationErrorsContainer extends React.Component
  constructor: (props, context) ->
    super(props, context)

  render: ->
    div(
      { className: 'validation-errors-container' }
      React.createElement(ValidationErrors,
        {
          validationErrors: @props.validationErrors
        }
      )
    )
