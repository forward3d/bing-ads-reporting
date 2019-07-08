module BingAdsReporting
  class Downloader
    include BingHelper

    attr_reader :report_url

    def initialize(report_url)
      @report_url = report_url
    end

    def self.fetch_report(report_url)
      new(report_url).fetch_report
    end

    def fetch_report
      logger.debug "Downloading Bing report from: #{report_url}"
      curl.perform
      curl.body_str
    end

    private

    def curl
      @curl ||= Curl::Easy.new(report_url)
    end
  end
end
