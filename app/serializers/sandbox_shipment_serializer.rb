class SandboxShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :taxon_name, #:reported_taxon_name, :accepted_taxon_name,
    :term_code, :quantity, :unit_code, :trading_partner, :country_of_origin,
    :export_permit, :origin_permit, :purpose_code, :source_code,
    :year, :import_permit, :updated_at, :updated_by, :editor

#  def reported_taxon_name
#    object.reported_taxon_concept && "#{object.reported_taxon_concept.full_name} (#{object.reported_taxon_concept.name_status})" ||
#    object.taxon_name
#  end
#
#  def accepted_taxon_name
#    object.taxon_concept && "#{object.taxon_concept.full_name} (#{object.taxon_concept.name_status})"
#  end
  #
  def updated_at
    if object.epix_updater
      object.epix_updated_at && object.epix_updated_at.strftime("%d/%m/%y")
    elsif object.sapi_updater
      object.updated_at && object.updated_at.strftime("%d/%m/%y")
    else
      nil
    end
  end

  def updated_by
    if object.epix_updater
      object.epix_updater.name
    elsif object.sapi_updater
      object.sapi_updater.name
    else
      nil
    end
  end

  def editor
    object.epix_updater ? 'epix' : 'sapi'
  end

end

