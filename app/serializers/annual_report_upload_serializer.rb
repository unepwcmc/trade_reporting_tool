class AnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :file_name, :created_at, :updated_at, :created_by, :updated_by,
  :submitted_at, :submitted_by,  :trading_country,
  :number_of_records_submitted,

  def file_name
    object.csv_source_file.try(:path) && File.basename(object.csv_source_file.path)
  end

  def created_at
    object.created_at.strftime("%d/%m/%y")
  end

  def updated_at
    object.updated_at.strftime("%d/%m/%y")
  end

  def created_by
    object.created_by && object.created_by.name
  end

  def updated_by
    object.created_by && object.updated_by.name
  end

  def submitted_at
    if object.epix_submitted_at
      object.epix_submitted_at.strftime("%d/%m/%y")
    elsif object.submitted_at
      object.submitted_at.strftime("%d/%m/%y")
    else
      nil
    end
  end

  def submitted_by
    if object.epix_submitter
      object.epix_submitter.first_name + ' ' +object.epix_submitter.last_name
    elsif object.sapi_submitter
      object.sapi_submitter.name
    else
      nil
    end
  end

  def trading_country
    object.trading_country && object.trading_country.name_en
  end

end

