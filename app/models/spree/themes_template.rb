module Spree
  class ThemesTemplate < Spree::Base

    DEFAULT_LOCALE = 'en'
    DEFAULT_PATH = "public/themes"

    ## VALIDATIONS ##
    validates :path, presence: true
    validates :format, inclusion: Mime::SET.symbols.map(&:to_s),
                       allow_nil: true
    validates :locale, inclusion: I18n.available_locales.map(&:to_s)
    validates :handler, inclusion: ActionView::Template::Handlers.extensions.map(&:to_s),
                        allow_nil: true

    ## ASSOCIATIONS ##
    belongs_to :theme

    ## CALLBACKS ##
    before_validation :set_default_locale, unless: :locale?
    before_create :set_public_path
    after_save :clear_cache
    after_save :update_public_file

    ## DELEGATES ##
    delegate :name, to: :theme, prefix: true

    private

      def clear_cache
        Spree::ThemesTemplate::Resolver.instance.clear_cache
      end

      def set_default_locale
        self.locale = DEFAULT_LOCALE
      end

      def set_public_path
        self.path = "#{ DEFAULT_PATH }/#{ theme_name }/#{ path }"
      end

      def update_public_file
        FileGeneratorService.create(self)
      end

  end
end