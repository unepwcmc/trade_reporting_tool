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
    @setBlank = @setBlank.bind(@)

  render: ->
    disabled_class = if @state.enabled then '' else 'disabled'
    name = if @state.form then "#{@state.form}[#{@state.name}]" else @state.name
    div(
      { className: "shipments-input-box #{disabled_class}" }
      span({ className: 'bold' }, @state.title)
      div({},
        input(
          {
            name: name,
            type: 'text'
            defaultValue: @state.value || ''
            ref: 'textInput'
          }
        )
      )
      @renderCheckbox() if @state.blankCheckbox
    )

  renderCheckbox: ->
    div(
      { className: 'blank-checkbox' }
      input(
        { type: 'checkbox', onClick: @setBlank }
      )
      span({}, 'Set blank')
    )

  setBlank: ->
    @setState({value: ' '})

  componentWillUpdate: (nextProps, nextState)->
    @refs.textInput.value = nextState.value


