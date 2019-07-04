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

      message = { ns('ReportRequest') => {
        ns('Format') => options[:report_format],
          ns('Language') => 'English',
          ns('ReportName') => options[:report_name],
          ns('ReturnOnlyCompleteData') => 'false',

          ns('Aggregation') => options[:aggregation],
          ns('Columns') => {
            ns("#{report_type}ReportColumn") => options[:columns]
          },
          ns('Scope') => {
            ns('AccountIds') => {
              'arr:long' => @settings[:accountId]
            }
          },
          ns('Time') => {
            # apparently order is important, and end date has to be before start date, wtf
            ns('CustomDateRangeEnd') => {
              ns('Day') => period.to.day,
              ns('Month') => period.to.month,
              ns('Year') => period.to.year
            },
            ns('CustomDateRangeStart') => {
              ns('Day') => period.from.day,
              ns('Month') => period.from.month,
              ns('Year') => period.from.year
            }
          }
      },
        :attributes! => {
          ns('ReportRequest') => {
            'i:type' => ns("#{report_type}ReportRequest"),
            'i:nil' => 'false'
          }
        } }

      message
    end

    def poll_operation
      :poll_generate_report
    end

    def generate_poll_message(id)
      { ns('ReportRequestId') => id }
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
