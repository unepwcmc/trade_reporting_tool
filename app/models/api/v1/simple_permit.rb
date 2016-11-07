class Api::V1::SimplePermit < WashOut::Type
  map SimplePermit: {
    Id: :string,
    TypeCode: :string,
    PurposeCode: :string,
    ConsignorCountryId: :string,
    ConsigneeCountryId: :string,
    SimplePermitLineItemList: [Api::V1::SimplePermitLineItem]
  }
end