{div, input, span} = React.DOM

window.InputBox = class InputBox extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      title: props.title
      enabled: props.enabled
      blankCheckbox: props.blankCheckbox || false
    }

  render: ->
    disabled_class = if @state.enabled then '' else 'disabled'
    div(
      { className: "shipments-input-box #{disabled_class}" }
      span({ className: 'bold' }, @state.title)
      div({},
        input({ type: 'text' })
      )
      @renderCheckbox() if @state.blankCheckbox
    )

  renderCheckbox: ->
    div(
      { className: 'blank-checkbox' }
      input({ type: 'checkbox' })
      span({}, 'Set blank')
    )


