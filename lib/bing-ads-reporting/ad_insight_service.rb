require_relative 'service_core'

module BingAdsReporting
  class AdInsightService < ServiceCore
    WDSL = 'https://reporting.api.bingads.microsoft.com/Api/Advertiser/Reporting/V12/ReportingService.svc?singleWsdl'.freeze
    FAILED_STATUS = 'Error'.freeze
    SUCCESS_STATUS = 'Success'.freeze

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

    def report_operation(_)
      :submit_generate_report
    end

    def generate_report_message(options)
      period = options[:period]
      report_type = options[:report_type]

      {
        ns('ReportRequest') => report_request(period, options, report_type),
        :attributes! => report_attributes(report_type)
      }
    end

    def report_request(period, options, report_type)
      {
        ns('Format') => options[:report_format],
        ns('Language') => 'English',
        ns('ReportName') => options[:report_name],
        ns('ReturnOnlyCompleteData') => 'false',
        ns('Aggregation') => options[:aggregation],
        ns('Columns') => { ns("#{report_type}ReportColumn") => options[:columns] },
        ns('Scope') => report_request_scope,
        ns('Time') => time(period)
      }
    end

    def report_request_scope
      {
        ns('AccountIds') => {
          'arr:long' => @settings[:accountId]
        }
      }
    end

    def report_attributes(report_type)
      {
        ns('ReportRequest') => {
          'i:type' => ns("#{report_type}ReportRequest"),
          'i:nil' => 'false'
        }
      }
    end

    def time(period)
      {
        # apparently order is important, and end date has to be before start date, wtf
        ns('CustomDateRangeEnd') => scope_data_range(period.to),
        ns('CustomDateRangeStart') => scope_data_range(period.from)
      }
    end

    def scope_data_range(period_range)
      day_key = ns('Day')
      month_key = ns('Month')
      year_key = ns('Year')

      {
        day_key => period_range.day,
        month_key => period_range.month,
        year_key => period_range.year
      }
    end

    def poll_operation
      :poll_generate_report
    end

    def generate_poll_message(report_id)
      { ns('ReportRequestId') => report_id }
    end

    def get_report_id(body, _)
      body[:submit_generate_report_response][:report_request_id]
    end

    def get_status(body)
      body[:poll_generate_report_response][:report_request_status][:status]
    rescue StandardError
      nil
    end

    def get_download_url(body)
      body[:poll_generate_report_response][:report_request_status][:report_download_url]
    rescue StandardError
      nil
    end
  end
end
