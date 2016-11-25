{a} = React.DOM
window.BatchEdit = class BatchEdit extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = { open: false }
    @toggleBatchEdit = @toggleBatchEdit.bind(@)

  render: ->
    a(
      {
        className: 'batch-edit-link green-link-underlined'
        onClick: @toggleBatchEdit
      }
      if @state.open
        I18n.t('close')
      else
        I18n.t('edit_all_errors')
    )

  toggleBatchEdit: ->
    @setState({open: !@state.open})
    $('.batch-edit-container').slideToggle()
