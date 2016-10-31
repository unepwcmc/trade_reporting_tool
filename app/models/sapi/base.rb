module Sapi
  class Base < ActiveRecord::Base
    self.abstract_class = true

    establish_connection(
      ActiveRecord::Base.configurations["sapi_#{Rails.env}"]
    )
  end
end
