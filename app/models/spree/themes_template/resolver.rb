module Spree
  class ThemesTemplate::Resolver < ActionView::Resolver

    include Singleton

    protected

      def theme
        @theme = Spree::Theme.published.first || default_theme
      end

      def default_theme
        @theme = Spree::Theme.default
      end

      def find_templates(name, prefix, partial, details)
        name = partial ? "_#{ name }" : name
        conditions = {
          path: normalize_path(name, prefix),
          locale: normalize_array(details[:locale]).first,
          format: normalize_array(details[:formats]).first,
          handler: normalize_array(details[:handlers]),
          partial: partial || false,
        }
        theme.themes_templates.where(conditions).map do |record|
          initialize_template(record)
        end
      end

      # Normalize name and prefix, so the tuple ["index", "users"] becomes
      # "users/index" and the tuple ["template", nil] becomes "template".
      def normalize_path(name, prefix)
        prefix.present? ? "#{ prefix }/#{ name }" : name
      end

      # Normalize arrays by converting all symbols to strings.
      def normalize_array(array)
        array.map(&:to_s)
      end

      # Initialize an ActionView::Template object based on the record found.
      def initialize_template(record)
        source = record.body
        identifier = "ThemesTemplate - #{record.id} - #{record.path.inspect}"
        handler = ActionView::Template.registered_template_handler(record.handler)
        details = {
          format: Mime[record.format],
          updated_at: record.updated_at,
          virtual_path: virtual_path(record.path, record.partial)
        }
        ActionView::Template.new(source, identifier, handler, details)
      end

      # Make paths as "users/user" become "users/_user" for partials.
      def virtual_path(path, partial)
        return path unless partial
        if index = path.rindex("/")
          path.insert(index + 1, "_")
        else
          "_#{path}"
        end
      end

  end
end