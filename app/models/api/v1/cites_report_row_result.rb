class Api::V1::CITESReportRowResult < WashOut::Type
  map CITESReportRowResult: {
    RowIndex: :integer,
    Errors: [:string]
  }
end