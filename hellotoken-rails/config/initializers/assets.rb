# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.5'

# css files
Rails.application.config.assets.precompile += %w( dashboard.css )
Rails.application.config.assets.precompile += %w( question.css )
Rails.application.config.assets.precompile += %w( mobile.css )
Rails.application.config.assets.precompile += %w( foundation_and_overrides.css )
Rails.application.config.assets.precompile += %w( ht-style.css )
Rails.application.config.assets.precompile += %w( main.css )

# vendor js files
Rails.application.config.assets.precompile += %w( mixpanel.min.js )
Rails.application.config.assets.precompile += %w( jquery.min.js )

# our js files
Rails.application.config.assets.precompile += %w( popup.js )
Rails.application.config.assets.precompile += %w( dashboard.js )


# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
