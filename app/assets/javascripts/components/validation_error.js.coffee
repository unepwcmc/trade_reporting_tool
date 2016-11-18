{div, a, i, span} = React.DOM
window.ValidationError = class ValidationError extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = { data: props.data }

  render: ->
    div(
      { className: 'validation-error' }
      div(
        { className: 'error-type' }
        if @state.data.is_primary then "Primary" else "Secondary"
      )
      div(
        { className: 'error-message' }
        @state.data.error_message
      )
    )
