class Api::V1::CitesReport < WashOut::Type
  map cites_report: {
    simple_permit: [Api::V1::SimplePermit]
  }
end