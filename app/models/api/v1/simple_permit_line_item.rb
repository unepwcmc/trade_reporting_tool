class Api::V1::SimplePermitLineItem < WashOut::Type
  map simple_permit_line_item: {
    scientific_name: :string,
    appendix: :string,
    source_code: :string,
    term_code: :string,
    origin_country_id: :string,
    origin_permit_id: :string,
    export_country_id: :string,
    export_permit_id: :string,
    quantity: :decimal,
    unit_code: :string
  }
end
