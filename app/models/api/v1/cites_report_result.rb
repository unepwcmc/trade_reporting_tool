class Api::V1::CITESReportResult < WashOut::Type
  map CITESReportResult: {
    status: :string,
    message: :string,
    details: [:string]
  }
end