require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'suspenders/lib/thor_extension'

module Suspenders
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, type: :string, aliases: "-d", default: "postgresql",
      desc: "Configure for selected database (options: #{DATABASES.join("/")})"

    class_option :devise, type: :boolean, default: true,
      desc: "Use devise for authentication"

    class_option :pundit, type: :boolean, default: true,
      desc: "Use pundit for authorization"

    class_option :role_field, type: :string,
      desc: 'Add role field to users table and make it enum with sensible default values for simple role management'

    class_option :carrierwave, type: :boolean,
      desc: 'Use carrierwave for image uploading and processing'



    class_option :heroku, type: :boolean, aliases: "-H", default: false,
      desc: "Create staging and production Heroku apps"

    class_option :heroku_flags, type: :string, default: "",
      desc: "Set extra Heroku flags"

    class_option :github, type: :string, aliases: "-G", default: nil,
      desc: "Create Github repository and add remote origin pointed to repo"

    class_option :skip_test_unit, type: :boolean, aliases: "-T", default: true,
      desc: "Skip Test::Unit files"

    class_option :skip_turbolinks, type: :boolean, default: true,
      desc: "Skip turbolinks gem"

    class_option :skip_bundle, type: :boolean, aliases: "-B", default: true,
      desc: "Don't run bundle install"

    def finish_template
      invoke :suspenders_customization
      super
    end

    def suspenders_customization
      invoke :ask_questions

      invoke :setup_ruby_version_and_gemset
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_production_environment
      invoke :setup_staging_environment
      invoke :setup_secret_token
      invoke :configure_app
      invoke :setup_gems
      invoke :configure_views
      invoke :setup_stylesheets

      # invoke :install_bitters
      # invoke :install_refills

      invoke :copy_miscellaneous_files
      invoke :customize_error_pages
      # invoke :remove_config_comment_lines
      # invoke :remove_routes_comment_lines

      invoke :setup_dotfiles
      invoke :setup_git
      invoke :setup_database

      invoke :create_heroku_apps
      invoke :create_github_repo

      invoke :setup_segment
      invoke :setup_bundler_audit
      invoke :setup_spring

      invoke :outro
    end

    def ask_questions
      say
      ask('')
      options[:carrierwave] = yes?('Use carrierwave for image uploading?', :yellow)
    end

    def setup_ruby_version_and_gemset
      build :setup_ruby_version_and_gemset

      bundle_command 'install'
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_on_delivery_errors
      # build :set_test_delivery_method
      build :provide_setup_script
      build :provide_dev_prime_task
    end

    def setup_test_environment
      say 'Setting up the test environment'
      # build :set_up_factory_girl_for_rspec
      build :generate_and_configure_rspec
      # build :configure_rspec
      # build :configure_ci
    end

    def setup_production_environment
      say 'Setting up the production environment'
      # build :configure_newrelic
      build :configure_smtp
      build :configure_rack_timeout
      # build :enable_rack_canonical_host
      # build :enable_rack_deflater
      build :setup_asset_host
    end

    def setup_staging_environment
      say 'Setting up the staging environment'
      build :setup_staging_environment
    end

    def setup_secret_token
      say 'Moving secret token out of version control'
      build :setup_secret_token
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :configure_active_job
      build :configure_time_formats
      build :raise_on_unpermitted_parameters
      build :configure_i18n_for_missing_translations
      # build :setup_default_rake_task
      build :configure_puma
      build :setup_foreman
    end

    def setup_gems
      say 'Setup i18n-tasks, simple_form'
      build :configure_i18n_tasks
      build :configure_simple_form
    end

    def configure_views
      say 'Creating views'
      build :create_views
      # build :create_partials_directory
      # build :create_shared_flashes
      # build :create_shared_javascripts
      # build :create_application_layout
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    # def install_bitters
    #   say 'Install Bitters'
    #   build :install_bitters
    # end

    # def install_refills
    #   say "Install Refills"
    #   build :install_refills
    # end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
      build :copy_miscellaneous_files
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_config_comment_lines
      build :remove_config_comment_lines
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def setup_dotfiles
      build :copy_dotfiles
    end

    def setup_git
      if !options[:skip_git]
        say 'Initializing git'
        invoke :setup_git
      end
    end

    def setup_database
      say 'Setting up database'

      if options[:database] == 'postgresql'
        build :use_postgres_config_template
      end

      build :create_database
    end

    def create_heroku_apps
      if options[:heroku]
        say "Creating Heroku apps"
        build :create_heroku_apps, options[:heroku_flags]
        # build :set_heroku_serve_static_files
        build :set_heroku_remotes
        build :set_heroku_rails_secrets
        build :provide_deploy_script
      end
    end

    def create_github_repo
      if !options[:skip_git] && options[:github]
        say 'Creating Github repo'
        build :create_github_repo, options[:github]
      end
    end

    def setup_segment
      say 'Setting up Segment'
      build :setup_segment
    end

    def setup_bundler_audit
      say "Setting up bundler-audit"
      build :setup_bundler_audit
    end

    def setup_spring
      say "Springifying binstubs"
      build :setup_spring
    end

    def outro
      say 'Congratulations! You just pulled our suspenders.'
      say "Remember to run 'rails generate airbrake' with your API key."
    end

    protected

    def get_builder_class
      Suspenders::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end

    def comment_if_not(value)
      options[value] ? '' : '# '
    end

    def ask_wizard(question)
      ask "\033[1m\033[36m" + ("option").rjust(10) + "\033[1m\033[36m" + "  #{question}\033[0m"
    end

    def whisper_ask_wizard(question)
      ask "\033[1m\033[36m" + ('choose').rjust(10) + "\033[0m" + "  #{question}"
    end

    def ask_multiple_choice(question, choices)
      say_custom('option', "\033[1m\033[36m" + "#{question}\033[0m")
      values = {}
      choices.each_with_index do |choice,i|
        values[(i + 1).to_s] = choice[1]
        say_custom( (i + 1).to_s + ')', choice[0] )
      end
      answer = whisper_ask_wizard("Enter your selection:") while !values.keys.include?(answer)
      values[answer]
    end

  end
end
