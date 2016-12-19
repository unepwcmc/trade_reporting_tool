{div, a, i, tr, td, span} = React.DOM
window.ShipmentVersion = class ShipmentVersion extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      shipment: props.shipment
      index: props.index
      changes: props.changes
      rowType: props.rowType
      userType: props.userType
    }

  render: ->
    data = @state.shipment
    keys = Object.keys(@state.changes)
    changes = ''
    if keys.length == 0
      changes = 'deleted'
    else if keys.length > 1
      changes = "#{keys.length} changes"
    else
      changes = "1 change"
    tr({ className: @state.rowType },
      td({}
        div({ className: "bold" }, data.updated_at)
        div({ className: "italic" }, changes)
      )
      td({}, span({ className: "appendix" }, data.appendix))
      td({},
        div(
          { className: "#{@state.index}_taxon_name bold" }
          data.taxon_name
        )
        div({ className: "#{@state.index}_accepted_name" }, data.taxon_name) # Replace with accepted_name
      )
      td({}, span({ className: "#{@state.index}_term" }, data.term))
      td({}, span({ className: "#{@state.index}_quantity" }, data.quantity))
      td({}, span({ className: "#{@state.index}_trading_partner" }, data.trading_partner))
      td({}, span({ className: "#{@state.index}_country_of_origin" }, data.country_of_origin))
      td({}, span({ className: "#{@state.index}_import_permit" }, data.import_permit))
      td({}, span({ className: "#{@state.index}_export_permit" }, data.export_permit))
      td({}, span({ className: "#{@state.index}_origin_permit" }, data.origin_permit))
      td({}
        span({ className: "#{@state.index}_purpose_code"}, data.purpose_code)
        " - "
        span({ className: "#{@state.index}_source_code" }, data.source_code)
        " - "
        span({ className: "#{@state.index}_year" }, + data.year)
      )
      td({}, span({ className: "#{@state.index}_updated_at"}, data.updated_at))
      @showEditor()
    )

  showEditor: ->
    editor = ''
    if @state.userType == 'sapi' || (@state.userType == @state.shipment.editor)
      editor = @state.shipment.updated_by
    else
      editor = 'WCMC'
    td({}, span({ className: "#{@state.index}_updated_by"}, editor))



  componentDidMount: ->
    keys = Object.keys(@state.changes)
    for key in keys
      regex = new RegExp(".*#{@state.index}_#{key}.*")
      $('td span').filter( ->
        if $(@).attr('class') && $(@).attr('class').match(regex)
          $(@).addClass('changed')
      )
