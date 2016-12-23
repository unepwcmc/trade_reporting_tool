module DownloadsCache
  def self.clear_shipments
    response = HTTParty.get("#{Rails.application.secrets.sapi_path}/api/trade_downloads_cache_cleanup")
  end
end
