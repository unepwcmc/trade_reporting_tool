module Sapi
  class GeoEntity < Sapi::Base
    belongs_to :geo_entity_type, class_name: Sapi::GeoEntityType

    scope :countries, -> {
                           includes(:geo_entity_type).
                           where('geo_entity_types.name' => 'COUNTRY').
                            order(:name_en)
                         }

    def name
      send("name_#{I18n.locale}")
    end

    def self.map_for_search
      name = "name_#{I18n.locale}"
      countries.pluck(:iso_code2, name)
    end
  end
end
