class Trade::InclusionValidationRule < Trade::ValidationRule

  def matching_records_for_aru_and_error(annual_report_upload, validation_error)
    sandbox_klass = annual_report_upload.sandbox.ar_klass
    @query = sandbox_klass.
      from("#{sandbox_klass.table_name}_view #{sandbox_klass.table_name}").
      where(
        "'#{validation_error.matching_criteria.to_json}'::JSONB @> (#{jsonb_matching_criteria_for_comparison})::JSONB"
      )
  end

  def error_message(values_hash = nil)
    scope_info = sanitized_sandbox_scope.map do |scope_column, scope_def|
      tmp = []
      if scope_def['inclusion']
        tmp << "#{scope_column} = #{scope_def['inclusion'].join(', ')}"
      end
      if scope_def['exclusion']
        tmp << "#{scope_column} != #{scope_def['exclusion'].join(', ')}"
      end
      if scope_def['blank']
        tmp << "#{scope_column} is empty"
      end
      tmp.join(' and ')
    end.compact.join(', ')
    info = column_names_for_matching.each_with_index.map do |cn|
      # for taxon concept validations output human readable taxon_name
      if cn == 'taxon_concept_id'
        "taxon_name #{values_hash && (values_hash['accepted_taxon_name'].blank? ? '[BLANK]' : values_hash['accepted_taxon_name'])}"
      else
        "#{cn} #{values_hash && (values_hash[cn].blank? ? '[BLANK]' : values_hash[cn])}"
      end
    end.join(" with ")
    info = "#{info} (#{scope_info})" unless scope_info.blank?
    info + ' is invalid'
  end

  def refresh_errors_if_needed(annual_report_upload)
    return true unless refresh_needed?(annual_report_upload)
    error_ids_to_destroy = validation_errors.pluck(:id)
    matching_records_grouped(annual_report_upload).map do |mr|
      values_hash = Hash[column_names.map { |cn| [cn, mr.send(cn)] }]
      values_hash_for_display = Hash[column_names_for_display.map { |cn| [cn, mr.send(cn)] }]
      matching_criteria_jsonb = jsonb_matching_criteria_for_comparison(
        values_hash
      )
      existing_record = validation_errors_for_aru(annual_report_upload).
        where("matching_criteria @> (#{matching_criteria_jsonb})::JSONB").first
      update_or_create_error_record(
        annual_report_upload,
        existing_record,
        mr.error_count.to_i,
        error_message(values_hash_for_display),
        values_hash
      )
      if existing_record
        error_ids_to_destroy.delete(existing_record.id)
      end
    end
    unless error_ids_to_destroy.empty?
      Trade::ValidationError.delete(error_ids_to_destroy)
    end
  end

  def validation_errors_for_shipment(shipment)
    return nil unless shipment_in_scope?(shipment)
    # if it is, check if it has a match in valid values view
    v = Arel::Table.new(valid_values_view)
    arel_nodes = shipments_columns.map { |c| v[c].eq(Arel::Nodes::Quoted.new(shipment.send(c))) }
    return nil if Trade::Shipment.find_by_sql(v.project(Arel.star).where(arel_nodes.inject(&:and))).any?
    error_message
  end

  private

  def column_names_for_matching
    column_names
  end

  def column_names_for_display
    if column_names.include?('taxon_concept_id') &&
      !column_names.include?('accepted_taxon_name')
        column_names << 'accepted_taxon_name'
    else
      column_names
    end
  end

  def jsonb_matching_criteria_for_comparison(values_hash = nil)
    jsonb_keys_and_values = column_names.map do |c|
      is_numeric = (c =~ /.+_id$/ || c == 'year')
      value_present = values_hash && values_hash.key?(c)
      value = value_present && values_hash[c]
      column_reference = c.to_s
      value_or_column_reference_quoted =
        if value_present && is_numeric
          value
        elsif value_present && !is_numeric
          "'\"#{value}\"'"
        elsif !value_present && is_numeric
          column_reference
        else
          <<-EOT
            '"' || #{column_reference} || '"'
          EOT
        end
      <<-EOT
        '"' || '#{c}' || '": ' || #{value_or_column_reference_quoted}
      EOT
    end.join("|| ', ' ||")
    "'{' || #{jsonb_keys_and_values} || '}'"
  end

  # Returns matching records grouped by column_names to return the count of
  # specific errors and ids of matching records
  def matching_records_grouped(annual_report_upload)
    sandbox_klass = annual_report_upload.sandbox.ar_klass
    table_name = annual_report_upload.sandbox.table_name
    matching_records = sandbox_klass.arel_table.create_table_alias(
      matching_records_arel(sandbox_klass.table_name),
      :matching_records
    )
    Trade::SandboxTemplate.
    select(
      column_names_for_display +
      [
        'COUNT(*) AS error_count',
        'ARRAY_AGG(id) AS matching_records_ids'
      ]
    ).
    from(matching_records).
    group(column_names_for_display).having(
      required_column_names.map { |cn| "#{cn} IS NOT NULL" }.join(' AND ')
    )
  end

  # Returns records from sandbox where values in column_names are not null
  # and optionally filtered down by specified scope
  # Pass Arel::Table
  def scoped_records_arel(s)
    not_null_nodes = required_column_names.map do |c|
      s[c].not_eq(nil)
    end
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each { |n| not_null_conds = not_null_conds.and(n) }
    result = s.project(Arel.star).where(not_null_conds)
    scope_nodes = sanitized_sandbox_scope.map do |scope_column, scope_def|
      tmp = []
      if scope_def['inclusion']
        inclusion_nodes = scope_def['inclusion'].map do |value|
          s[scope_column].eq(Arel::Nodes::Quoted.new(value))
        end
        tmp << inclusion_nodes.inject(&:or)
      end
      if scope_def['exclusion']
        exclusion_nodes = scope_def['exclusion'].map do |value|
          s[scope_column].not_eq(Arel::Nodes::Quoted.new(value))
        end
        tmp << exclusion_nodes.inject(&:or)
      end
      if scope_def['blank']
        tmp << s[scope_column].eq(nil)
      end
      tmp
    end.flatten
    scope_conds = scope_nodes.inject(&:and)
    result = result.where(scope_conds) if scope_conds
    result
  end

  # Returns records from sandbox where values in column_names are not included
  # in valid_values_view.
  # The valid_values_view should have the same column names and data types as
  # the sandbox columns specified in column_names.
  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    v = Arel::Table.new(valid_values_view)
    join_nodes = column_names_for_matching.map do |c|
      if required_column_names.include? c
        v[c].eq(s[c])
      else
        # if optional, check if NULL is allowed for this particular combination
        # e.g. unit code can be blank only if paired with certain terms
        v[c].eq(s[c]).or(v[c].eq(nil).and(s[c].eq(nil)))
      end
    end
    valid_values = s.project(s[Arel.star]).join(v).on(join_nodes.inject(&:and))
    scoped_records_arel(s).except(valid_values)
  end

end
