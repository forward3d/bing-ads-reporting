require_relative 'service_core'

module BingAdsReporting
  class InsightService < ServiceCore
    WDSL = 'https://adinsight.api.bingads.microsoft.com/Api/Advertiser/AdInsight/v13/AdInsightService.svc?singleWsdl'.freeze
    FAILED_STATUS = 'Error'.freeze
    SUCCESS_STATUS = 'Success'.freeze
    attr_reader :request_class

    def initialize(settings, logger = nil, request_class)
      @request_class = request_class

      super(settings, logger)
    end

    def generate_report(report_settings, report_params)
      options = default_options(report_settings).merge(report_params)
      response = call_operation(options)

      response_result(response, options)
    end

    private

    def wdsl
      WDSL
    end

    def failed_status
      FAILED_STATUS
    end

    def success_status
      SUCCESS_STATUS
    end

    def response_result(response, options)
      tag = response_tag(options)
      response.body[tag]
    end

    def response_tag(options)
      "#{report_operation(options)}_response".to_sym
    end

    def report_operation(options)
      BingHelper.camel_case_to_sym(options[:report_type])
    end

    def generate_report_message(options)
      period = options[:period]

      request_class.message(period, options)
    end
  end
end
