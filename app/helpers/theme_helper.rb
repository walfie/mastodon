# frozen_string_literal: true

module ThemeHelper
  def stylesheet_for_layout
    theme_pack = "theme_#{site_theme_for_user}.css"

    if asset_exist? theme_pack
      theme_pack
    else
      'default'
    end
  end

  def site_theme_for_user
    current_user&.account&.user&.setting_theme || Setting.theme
  rescue
    Setting.site_theme
  end

  THEME_COLORS = {
    'default' => '#282c37',
    'kkt' => '#df57a4'
  }.freeze

  # For Android tab color
  def theme_color_for_user
    THEME_COLORS[site_theme_for_user] || THEME_COLORS['default']
  end

  def asset_exist?(path)
    true if Webpacker::Manifest.lookup(path)
  rescue Webpacker::FileLoader::NotFoundError
    false
  end
end

