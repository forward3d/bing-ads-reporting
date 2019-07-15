require_relative 'service_core'

module BingAdsReporting
  class AdInsightReal < ServiceCore
    WDSL = 'https://adinsight.api.bingads.microsoft.com/Api/Advertiser/AdInsight/v13/AdInsightService.svc?singleWsdl'.freeze
    FAILED_STATUS = 'Error'.freeze
    SUCCESS_STATUS = 'Success'.freeze

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
      report_type = options[:report_type]

      report_request(period, options, report_type)
    end

    def report_request(period, _options, _report_type)
      {
        'EntityType' => 'Account',
        'SearchParameters' => {
          'SearchParameter' =>  date_range(period)
        },
        '@xsi:type' => 'tns:DateRangeSearchParameter'
      }
    end


    def date_range(period)
      {
        'EndDate' => scope_data_range(period.to),
        'StartDate' => scope_data_range(period.from),
        '@i:type' => 'tns:DateRangeSearchParameter'
      }
    end

    def scope_data_range(period_range)
      {
        ns('Day') => "#{period_range.day}",
        ns('Month') => "#{period_range.month}",
        ns('Year') => "#{period_range.year}"
      }
    end
  end
end
