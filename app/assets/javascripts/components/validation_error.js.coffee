{div, a, i, span} = React.DOM
window.ValidationError = class ValidationError extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      data: props.data
      type: if props.data.is_primary then "primary" else "secondary"
    }
    @ignoreValidationError = @ignoreError.bind(@)

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
      @renderIgnore() if @state.type == 'secondary'
    )

  renderIgnore: ->
    span(
      {
        className: 'ignore-button button'
        onClick: @ignoreValidationError
      }
      "#{I18n.t('ignore')}"
    )

  ignoreError: ->

