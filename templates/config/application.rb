require File.expand_path('../boot', __FILE__)

<% if include_all_railties? -%>
require 'rails/all'
<% else -%>
require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
<%= comment_if :skip_active_record %>require "active_record/railtie"
require "action_controller/railtie"
<%= comment_if :skip_action_mailer %>require "action_mailer/railtie"
require "action_view/railtie"
<%= comment_if :skip_sprockets %>require "sprockets/railtie"
<%= comment_if :skip_test %>require "rails/test_unit/railtie"
<% end -%>

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require platform-specific gems
platform = RUBY_PLATFORM.match(/(linux|darwin)/)[0].to_sym
Bundler.require(platform)

module <%= app_const_base %>
  class Application < Rails::Application
    require_all "#{Rails.root}/lib/extensions"
    require_all "#{Rails.root}/lib/logging" if !Rails.env.production?
    <%= comment_if_not :carrierwave %>require_all "#{Rails.root}/lib/carrierwave"
    require_all "#{Rails.root}/lib/virtus"
    <%= comment_if_not :devise %>require_all "#{Rails.root}/lib/devise"
    require_all "#{Rails.root}/lib/simple_form"

    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
