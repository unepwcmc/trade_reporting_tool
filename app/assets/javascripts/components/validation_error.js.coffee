{div, a, i, span} = React.DOM
window.ValidationError = class ValidationError extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: props.data
      type: if props.data.is_primary then "primary" else "secondary"
    }

  render: ->
    div(
      { className: 'validation-error' }
      div(
        { className: "error-type #{@state.type}" }
        i({}, @state.type)
      )
      div(
        { className: 'error-message' }
        a(
          { href: '#' }
          @state.data.error_message
        )
      )
    )
