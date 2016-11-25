{a} = React.DOM
window.BatchEdit = class BatchEdit extends React.Component
  render: ->
    a(
      {
        className: 'batch-edit-link green-link-underlined'
        onClick: @toggleBatchEdit
      }
      I18n.t('edit_all_errors')
    )

  toggleBatchEdit: ->
    $('.batch-edit-container').slideToggle()
