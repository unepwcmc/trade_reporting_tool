{div, input, span, a, i, button, ul, li } = React.DOM
window.Dropdown = class Dropdown extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      title: props.title,
      name: props.name,
      placeholder: props.placeholder,
      data: props.data,
      selection: null,
      enabled: props.enabled,
      blankCheckbox: props.blankCheckbox || false
      value: props.value
      form: props.form
    }
    @processSelection = @processSelection.bind(@)

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
        span({}, (@state.selection || @state.value || @state.placeholder))
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
        }
      )

    )

  renderCheckbox: ->
    div(
      { className: 'blank-checkbox' }
      input({ type: 'checkbox' })
      span({}, 'Set blank')
    )

  processSelection: (e) ->
    item = $(e.currentTarget).find('a').html()
    $(e.currentTarget).closest('div').find('input').attr('value', item)
    @setState({selection: item})

