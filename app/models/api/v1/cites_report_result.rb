class Api::V1::CITESReportResult < WashOut::Type
  map CITESReportResult: {
    status: :string,
    message: :string,
    errors: [Api::V1::CITESReportRowResult]
  }
end