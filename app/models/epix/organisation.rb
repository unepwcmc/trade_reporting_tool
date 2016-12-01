module Epix
  class Organisation < Epix::Base
    CITES_MA = 'CITES MA'
    CUSTOMS_EA = 'Customs EA'
    SYSTEM_MANAGERS = 'System Managers'
    OTHER = 'Other'

    AUTHORISED = [CITES_MA, SYSTEM_MANAGERS]

    belongs_to :country
  end
end
