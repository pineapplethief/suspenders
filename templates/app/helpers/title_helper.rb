module TitleHelper

  def title(additional_context = {}, opts = {})
    if content_for?(:title)
      provide(:title)
    else
      context = controller.view_assigns.merge(additional_context).symbolize_keys
      PageTitle.new(controller_path, action_name, context, opts)
    end
  end

  class PageTitle
    attr_reader :controller_path, :action_name, :context,
                :application_name, :include_application_name, :separator

    def initialize(controller_path, action_name, context, opts)
      @controller_path = controller_path
      @action_name = action_name
      @context = context
      @application_name = opts[:application_name] || humanized_application_name
      @include_application_name = opts[:include_application_name] || true
      @separator = opts[:separator] || ' – '
    end

    def to_s
      title = translate_action
      if include_application_name
        title << "#{separator}#{application_name}" if title != application_name
      end
      title
    end

    private

    def translate_application_name
      return application_name if application_name.present?
      I18n.t(application_title, default: humanized_application_name)
    end

    def humanized_application_name
      guess_title_key.underscore.humanize.gsub(/\S+/, &:capitalize)
    end

    def translate_action
      I18n.t("titles.#{controller_i18n_key_lookup_path}.#{action_name}",
             context.merge(default: defaults))
    end

    def application_title_key
      :'titles.application'
    end

    def guess_title_key
      Rails.application.class.to_s.split('::').first
    end

    def controller_i18n_key_lookup_path
      controller_path.gsub('/', '.')
    end

    def defaults
      default_keys_in_lookup_path + [application_title_key, guess_title_key]
    end

    def default_keys_in_lookup_path
      defaults = []
      lookup_path = controller_i18n_key_lookup_path.split('.')
      while lookup_path.length > 0
        defaults << ['titles', *lookup_path, 'default'].join('.').to_sym
        lookup_path.pop
      end
      defaults.reverse
    end

  end

end
