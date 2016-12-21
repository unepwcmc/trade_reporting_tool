{div, input, span, a, i, button, ul, li, select, option } = React.DOM
window.Dropdown = class Dropdown extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      title: props.title,
      name: props.name,
      placeholder: props.placeholder,
      data: props.data,
      enabled: props.enabled,
      blankCheckbox: props.blankCheckbox || false
      value: props.value
      form: props.form
    }
    @setBlank = @setBlank.bind(@)

  render: ->
    disabled_class = if @state.enabled then '' else 'disabled'
    div(
      { className: "shipments-dropdown #{disabled_class}" }
      span({ className: 'bold' }, @state.title)
      @renderDropdown()
      @renderCheckbox() if @state.blankCheckbox
    )

  renderDropdown: ->
    name = if @state.form then "#{@state.form}[#{@state.name}]" else @state.name
    div(
      {}
      select(
        {
          id: "#{@state.name}_dropdown",
          className: 'dropdown-menu',
          name: name
        }
        option(
          { defaultValue: @state.value }
          @state.value
        )
      )
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

  componentDidMount: ->
    data = []
    if @state.name in ['trading_partner', 'country_of_origin']
      data = @state.data.map (value) ->
        id: value[0]
        text: value[1]
    else
      data = @state.data.map (value) ->
        id: value
        text: value
    $("##{@state.name}_dropdown").select2({
      placeholder: @state.placeholder,
      data: data
    })

