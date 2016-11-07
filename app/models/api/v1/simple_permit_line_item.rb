class Api::V1::SimplePermitLineItem < WashOut::Type
  map SimplePermitLineItem: {
    ScientificName: :string,
    Appendix: :string,
    SourceCode: :string,
    TermCode: :string,
    OriginCountryId: :string,
    OriginPermitId: :string,
    ExportCountryId: :string,
    ExportPermitId: :string,
    Quantity: :double,
    UnitCode: :string
  }
end
