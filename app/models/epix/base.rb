module Epix
  class Base < ActiveRecord::Base
    self.abstract_class = true

    establish_connection(
      ActiveRecord::Base.configurations["epix_#{Rails.env}"]
    )
  end
end
