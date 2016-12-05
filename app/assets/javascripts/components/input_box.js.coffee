{div, input, span} = React.DOM

window.InputBox = class InputBox extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      title: props.title
      name: props.name
      enabled: props.enabled
      blankCheckbox: props.blankCheckbox || false
      value: props.value
      form: props.form
    }

  render: ->
    disabled_class = if @state.enabled then '' else 'disabled'
    div(
      { className: "shipments-input-box #{disabled_class}" }
      span({ className: 'bold' }, @state.title)
      div({},
        input(
          {
            name: "#{@state.form}[#{@state.name}]",
            type: 'text'
            defaultValue: @state.value || ''
          }
        )
      )
      @renderCheckbox() if @state.blankCheckbox
    )

  renderCheckbox: ->
    div(
      { className: 'blank-checkbox' }
      input({ type: 'checkbox' })
      span({}, 'Set blank')
    )


