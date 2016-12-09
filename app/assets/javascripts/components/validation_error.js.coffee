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
    base_url = "/annual_report_uploads/#{@state.data.annual_report_upload_id}"
    div(
      { className: 'validation-error' }
      div(
        { className: "error-type #{@state.type}" }
        i({}, @state.type)
      )
      div(
        { className: 'error-message' }
        a(
          { href: base_url + "/validation_errors/#{@state.data.id}/shipments" }
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

