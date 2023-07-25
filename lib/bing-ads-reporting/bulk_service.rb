require_relative 'service_core'

module BingAdsReporting
  class BulkService < ServiceCore
    WDSL = 'https://bulk.api.bingads.microsoft.com/Api/Advertiser/CampaignManagement/V13/BulkService.svc?singleWsdl'.freeze
    FAILED_STATUS = 'Failed'.freeze
    SUCCESS_STATUS = 'Completed'.freeze

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

    def report_operation(options)
      options[:report_type].split(/(?=[A-Z])/).join('_').downcase.to_sym
    end

    def report_operation_response(options)
      "#{report_operation(options)}_response".to_sym
    end

    def generate_report_message(options)
      period = options[:period]
      data_scope = options[:data_scope]

      message = report_message(options, data_scope)
      message
    end

    def report_message(options, data_scope)
      {
        ns('AccountIds') => { 'arr:long' => @settings[:accountId] },
        ns('CompressionType') => 'Zip',
        ns('DataScope') => data_scope,
        ns('DownloadEntities') => { ns('DownloadEntity') => options[:download_entities] },
        ns('DownloadFileType') => options[:report_format],
        ns('FormatVersion') => '6.0',
        ns('LastSyncTimeInUtc') => true
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
      :get_bulk_download_status
    end

    def generate_poll_message(report_id)
      { ns('RequestId') => report_id }
    end

    def get_report_id(body, options)
      body[report_operation_response(options)][:download_request_id]
    end

    def get_status(body)
      body[:get_bulk_download_status_response][:request_status]
    rescue StandardError
      nil
    end

    def get_download_url(body)
      body[:get_bulk_download_status_response][:result_file_url]
    rescue StandardError
      nil
    end
  end
end
