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
      apiBaseUrl: props.apiBaseUrl
      isBlank: false
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
    @setState({isBlank: !@state.isBlank})

  componentDidMount: ->
    data = []
    if @state.name in ['trading_partner', 'country_of_origin']
      data = @state.data.map (value) ->
        id: value[0]
        text: value[1]
    else if @state.name == 'taxon_name'
      @select2TaxonConcept()
      return
    else
      data = @state.data.map (value) ->
        id: value
        text: value
    $("##{@state.name}_dropdown").select2({
      placeholder: @state.placeholder,
      data: data
    })

  componentDidUpdate: ->
    dropdown = "##{@state.name}_dropdown"
    if @state.isBlank
      $(dropdown).html('').select2({data: [{id: '', text: ''}]})
    else
      data = @state.data.map (value) ->
        id: value
        text: value
      $(dropdown).html('').select2({data: data}).val(@state.value).trigger('change')

  select2TaxonConcept: ->
    $("#taxon_name_dropdown").select2({
      minimumInputLength: 3
      quietMillis: 500,
      ajax:
        url: "#{@state.apiBaseUrl}/api/v1/auto_complete_taxon_concepts.json"
        dataType: 'json'
        data: (term, page) =>
          taxon_concept_query: term.term # search term
          #visibility: 'trade_internal' #includes status
          include_synonyms: true
          per_page: 10
          page: page
        processResults: (data, page) => # parse the results into the format expected by Select2.
          more = (page * 10) < data.meta.total
          formatted_taxon_concepts = data.auto_complete_taxon_concepts.map (tc) =>
            nameStatusFormatted = unless tc.name_status == 'A'
              ' [' + tc.name_status + ']'
            else
              ''
            id: tc.full_name
            text: tc.full_name + nameStatusFormatted
          results: formatted_taxon_concepts
          more: more
    })
