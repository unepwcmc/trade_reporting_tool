class ShowAnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :file_name, :has_primary_errors, :created_at, :updated_at,
  :created_by, :updated_by, :summary, :has_validation_report,
  :validation_errors, :ignored_validation_errors

  def validation_errors
    object.validation_errors.reject do |ve|
      ve.is_ignored
    end.sort_by(&:error_message)
  end

  def ignored_validation_errors
    object.validation_errors.select do |ve|
      ve.is_ignored
    end.sort_by(&:error_message)
  end

  def has_primary_errors
    !validation_errors.index { |ve| ve.is_primary }.nil?
  end

  def created_at
    if object.epix_created_at
      object.epix_created_at.strftime("%d/%m/%y")
    elsif object.created_at
      object.created_at.strftime("%d/%m/%y")
    else
      nil
    end
  end

  def updated_at
    if object.epix_updater
      object.epix_updated_at && object.epix_updated_at.strftime("%d/%m/%y")
    elsif object.sapi_updater
      object.updated_at && object.updated_at.strftime("%d/%m/%y")
    else
      nil
    end
  end

  def created_by
    if object.epix_creator
      object.epix_creator.name
    elsif object.sapi_creator
      object.sapi_creator.name
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

  def summary
    _created_at = (object.epix_created_at || object.created_at).strftime("%d/%m/%y")
    _created_by = (object.epix_creator || object.sapi_creator).name
    object.trading_country.name_en + ' (' + object.point_of_view + '), ' +
      object.number_of_rows.to_s + ' shipments' + ' uploaded on ' + _created_at +
      ' by ' + _created_by + ' ('  + (file_name || '') + ')'
  end

  def has_validation_report
    object.validation_report.present?
  end
end
