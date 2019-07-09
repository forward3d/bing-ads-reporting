module BingAdsReporting
  module BingHelper
    def ns(str)
      "tns:#{str}"
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
