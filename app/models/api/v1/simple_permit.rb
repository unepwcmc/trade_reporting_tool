class Api::V1::SimplePermit < WashOut::Type
  map simple_permit: {
    id: :string,
    type_code: :string,
    purpose_code: :string,
    consignor_country_id: :string,
    consignee_country_id: :string,
    simple_permit_line_item: [Api::V1::SimplePermitLineItem]
  }
end