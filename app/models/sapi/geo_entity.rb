module Sapi
  class GeoEntity < Sapi::Base
    belongs_to :geo_entity_type, class_name: Sapi::GeoEntityType

    scope :countries, -> {
                           includes(:geo_entity_type).
                           where('geo_entity_types.name' => 'COUNTRY')
                         }

    def name
      send("name_#{I18n.locale}")
    end

    def self.map_for_search
      countries.order(:iso_code2).pluck(:iso_code2)
    end
  end
end
