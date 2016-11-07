class AnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :file_name, :is_done, :created_at, :updated_at, :created_by, :updated_by

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

end

