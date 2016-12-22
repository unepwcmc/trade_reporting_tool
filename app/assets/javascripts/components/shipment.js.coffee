{div, a, i, tr, td} = React.DOM
window.Shipment = class Shipment extends React.Component
  constructor: (props, context) ->
    super(props, context)
    @state = {
      shipment: props.shipment
      rowType: props.rowType
      annualReportUploadId: props.annualReportUploadId
      changesHistory: props.changesHistory
    }

  render: ->
    data = @state.shipment
    base_url =
      "/annual_report_uploads/#{@state.annualReportUploadId}/shipments/#{@state.shipment.id}"
    tr({ className: @state.rowType },
      if @state.changesHistory
        td({}, '')
      td({}, data.appendix)
      td({},
        div(
          { className: 'bold' }
          data.reported_taxon_name
        )
        div({}, data.accepted_taxon_name)
      )
      td({}, data.term)
      td({}, data.quantity)
      td({}, data.trading_partner)
      td({}, data.country_of_origin)
      td({}, data.import_permit)
      td({}, data.export_permit)
      td({}, data.origin_permit)
      td({}
        data.purpose_code + ' - ' + data.source_code + ' - ' + data.year
      )
      unless @state.changesHistory
        td({ className: 'actions-col' },
          div(
            {}
            a(
              {
                className: 'green-link-underlined'
                href: base_url + "/edit"
              }
              i({ className: 'fa fa-pencil-square-o'})
              " #{I18n.t('edit')}"
            )
          )
          div(
            {}
            a(
              {
                className: 'green-link-underlined'
                href: base_url
                "data-method": 'delete'
                "data-confirm": 'Are you sure you want to delete this shipment?'
              }
              i({ className: 'fa fa-times' })
              " #{I18n.t('delete')}"
            )
          )
        )
    )
