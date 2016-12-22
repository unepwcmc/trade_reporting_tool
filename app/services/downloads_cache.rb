module DownloadsCache

  def self.downloads_path(dir)
    "#{Rails.root}/public/downloads/#{dir}"
  end

  def self.clear_dirs(dirs)
    dirs.each do |dir|
      Rails.logger.debug("Clearing #{dir}")
      FileUtils.rm_rf(Dir["#{downloads_path(dir)}/*"], :secure => true)
    end
  end

  # cleared after save & destroy
  def self.clear_shipments
    clear_dirs(['shipments'])
    clear_dirs(['comptab'])
    clear_dirs(['gross_exports'])
    clear_dirs(['gross_imports'])
    clear_dirs(['net_exports'])
    clear_dirs(['net_imports'])
  end
end
