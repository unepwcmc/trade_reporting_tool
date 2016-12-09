{div, input, span, a, i, button, ul, li } = React.DOM
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
    @processSelection = @processSelection.bind(@)
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
      button(
        { "data-toggle": 'dropdown' }
        span({}, (@state.value || @state.placeholder))
        i({ className: 'fa fa-caret-down'})
      )
      ul(
        { className: 'dropdown-menu' }
        for item in @state.data
          li({ key: item, onClick: @processSelection },
            a({}, item)
          )
      )
      input(
        {
          className: 'dropdown-input',
          name: name
          type: 'text',
          defaultValue: @state.value || ''
          ref: 'textInput'
        }
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

  processSelection: (e) ->
    item = $(e.currentTarget).find('a').html()
    @setState({value: item})

  setBlank: ->
    @setState({value: ' '})

  componentWillUpdate: (nextProps, nextState)->
    @refs.textInput.value = nextState.value

