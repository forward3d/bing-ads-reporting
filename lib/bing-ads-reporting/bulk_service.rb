module BingAdsReporting
  class BulkService < CoreService

    WDSL = "https://bulk.api.bingads.microsoft.com/Api/Advertiser/CampaignManagement/V11/BulkService.svc?wsdl".freeze
    FAILED_STATUS = "Failed".freeze
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

    def report_operation
      :download_campaigns_by_account_ids
    end

    def generate_report_message(options)
      period = options[:period]
      data_scope = options[:data_scope]

      message = {
        ns("AccountIds") => {
          'arr:long' => @settings[:accountId]
        },
        ns("CompressionType") => 'Zip',
        ns("DataScope") => data_scope,
        ns("DownloadEntities") => {
          ns("DownloadEntity") => options[:download_entities]
        },
        ns("DownloadFileType") => options[:report_format],
        ns("FormatVersion") => '5.0',
        ns("LastSyncTimeInUtc") => true,
      }

      if data_scope == 'EntityPerformanceData'
        message[ns("PerformanceStatsDateRange")] = {
          # apparently order is important, and end date has to be before start date, wtf
          ns("CustomDateRangeEnd") => {
            ns("Day") => period.to.day,
            ns("Month") => period.to.month,
            ns("Year") => period.to.year
          },
          ns("CustomDateRangeStart") => {
            ns("Day") => period.from.day,
            ns("Month") => period.from.month,
            ns("Year") => period.from.year
          }
          # ns("PredefinedTime") => options[:time]
        }
      end
      message
    end

    def poll_operation
      :get_bulk_download_status
    end

    def generate_poll_message(id)
      { ns("RequestId") => id }
    end

    def get_report_id(body)
      body[:download_campaigns_by_account_ids_response][:download_request_id]
    end

    def get_status(body)
      body[:get_bulk_download_status_response][:request_status] rescue nil
    end

    def get_download_url(body)
      body[:get_bulk_download_status_response][:result_file_url] rescue nil
    end

  end
end
