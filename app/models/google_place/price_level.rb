class GooglePlace
  class PriceLevel
    GOOGLE_PRICE_LEVELS = {
      PRICE_LEVEL_UNSPECIFIED: -1,
      PRICE_LEVEL_FREE: 0,
      PRICE_LEVEL_INEXPENSIVE: 1,
      PRICE_LEVEL_MODERATE: 2,
      PRICE_LEVEL_EXPENSIVE: 3,
      PRICE_LEVEL_VERY_EXPENSIVE: 4
    }

    attr_reader :google_price_level

    def initialize(google_price_level:)
      @google_price_level = google_price_level.to_s
    end

    def to_i = level

    def to_s = humanized_level

    private

    def level
      return -1 unless google_price_level

      @level ||= GOOGLE_PRICE_LEVELS.fetch(google_price_level.to_sym, -1)
    end

    def humanized_level
      @humanized_level ||= google_price_level.split("_").last.capitalize
    end
  end

  private_constant :PriceLevel
end
