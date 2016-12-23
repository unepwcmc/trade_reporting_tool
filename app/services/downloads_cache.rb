module DownloadsCache
  def self.clear_shipments
    Rails.logger.info(
      HTTParty.get("#{Rails.application.secrets.sapi_path}/api/trade_downloads_cache_cleanup")
    )
  end
end
