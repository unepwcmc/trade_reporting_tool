class DownloadsCacheCleanupJob < ApplicationJob
  queue_as :default

  def perform(type_of_cache)
    DownloadsCache.send(:"clear_#{type_of_cache}")
  end
end
