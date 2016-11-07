class Api::V1::CitesReport < WashOut::Type
  map CITESReport: {
    SimplePermitList: [Api::V1::SimplePermit]
  }
end