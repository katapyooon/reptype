module ApplicationHelper
  def morphs_catalog_enabled?
    Rails.application.config.x.morphs_catalog_enabled
  end
end
