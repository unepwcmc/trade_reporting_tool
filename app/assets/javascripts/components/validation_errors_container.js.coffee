{div, a, span} = React.DOM

window.ValidationErrorsContainer = class ValidationErrorsContainer extends React.Component
  constructor: (props, context) ->
    super(props, context)

  render: ->
    div(
      { className: 'validation-errors-container' }
      React.createElement(ValidationErrors,
        {
          key: 'validation_errors'
          validationErrors: @props.validationErrors
        }
      )
      if @props.ignoredValidationErrors.length > 0
        div({className: 'border-btm'})
        @renderIgnoredErrors(@props)
    )

  renderIgnoredErrors: (props) ->
    React.createElement(ValidationErrors,
      {
        key: 'ignored_errors'
        validationErrors: props.ignoredValidationErrors
        ignored: true
      }
    )
