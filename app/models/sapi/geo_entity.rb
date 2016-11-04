module Sapi
  class GeoEntity < Sapi::Base
    belongs_to :geo_entity_type, class_name: Sapi::GeoEntityType
  end
end
