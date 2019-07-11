module BingAdsReporting
  module BingHelper
    def ns(str)
      "tns:#{str}"
    end

    def self.camel_case_to_sym(word)
      word.split(/(?=[A-Z])/).map(&:downcase).join('_').to_sym
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
