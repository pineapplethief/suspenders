ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)
abort('DATABASE_URL environment variable is set') if ENV['DATABASE_URL']

require 'rspec/rails'
require 'shoulda/matchers'

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  # include Formulaic::Dsl
end

RSpec.configure do |config|
  config.include Features, type: :feature
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  # add factory girl methods
  config.include FactoryGirl::Syntax::Methods

  # to use t and l methods fron I18n in specs easily
  config.include AbstractController::Translation

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  # database-cleaner configuration
  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

ActiveRecord::Migration.maintain_test_schema!
# Capybara.javascript_driver = :webkit
