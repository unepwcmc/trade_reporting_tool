class Api::V1::CITESReportRow < WashOut::Type
  map CITESReportRow: {
    TradingPartnerId: :string,
    Year: :integer,
    ScientificName: :string,
    Appendix: :string,
    TermCode: :string,
    Quantity: :double,
    UnitCode: :string,
    SourceCode: :string,
    PurposeCode: :string,
    OriginCountryId: :string,
    OriginPermitId: :string,
    ExportPermitId: :string,
    ImportPermitId: :string
  }
end