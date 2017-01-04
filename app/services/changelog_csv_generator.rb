require 'csv'
class ChangelogCsvGenerator

  def self.call(aru, requester, aws=false)
    data_columns = if aru.reported_by_exporter?
      Trade::SandboxTemplate::EXPORTER_COLUMNS
    else
      Trade::SandboxTemplate::IMPORTER_COLUMNS
    end
    requester_type = if requester.is_a?(Sapi::User) && requester.role == Sapi::User::MANAGER
      'sapi'
    else
      'epix'
    end

    epix_users = Hash[
      Epix::User.select(:id, :first_name, :last_name).all.map{ |u| [u.id, u.name] }
    ]

    if requester_type == 'sapi'
      # only allow to see name of Sapi user if requested by Sapi manager
      sapi_users = Hash[
        Sapi::User.select(:id, :name).all.map{ |u| [u.id, u.name] }
      ]
    end

    tempfile = Tempfile.new(["changelog_#{requester_type}_#{aru.id}-", ".csv"], Rails.root.join('tmp'))

    CSV.open(tempfile, 'w', headers: true) do |csv|
      csv << ['ID', 'Version', 'OP', 'ChangedAt', 'ChangedBy'] +
        data_columns.map(&:camelize)
      limit = 100
      offset = 0
      query = aru.sandbox.ar_klass.includes(:versions).limit(limit).offset(offset)
      while query.any?
        query.all.each do |shipment|
          csv << [shipment.id, nil, nil, shipment.created_at, nil] +
            data_columns.map do |dc|
              shipment[dc]
            end

          shipment.versions.each do |version|
            reified = version.reify(dup: true)
            type, id = version.whodunnit && version.whodunnit.split(':')
            id_as_number = id.present? && id.to_i
            whodunnit = if id_as_number && type == 'Epix'
              epix_users[id_as_number] || 'epix'
            elsif id_as_number && type == 'Sapi'
              if aws
                'WCMC'
              else
                sapi_users && sapi_users[id_as_number] || 'WCMC'
              end
            end
            csv << [
                version.item_id, version.id, version.event, version.created_at, whodunnit
              ] +
              data_columns.map do |dc|
                reified[dc]
              end
          end

          offset += limit
          query = aru.sandbox.ar_klass.includes(:versions).limit(limit).offset(offset)
        end
      end
    end
    tempfile
  end

end
