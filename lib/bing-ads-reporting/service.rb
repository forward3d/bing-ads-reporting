module BingAdsReporting
  class Service
    def initialize(settings, logger = Logger.new($stdout))
      @account_id = settings[:account_id]
      @client = Client.new(settings, logger)
    end

    def generate_report(report_settings, report_params)
      options = default_options(report_settings).merge(report_params)
      submit_generate_report(options)
    end

    def report_ready?(id)
      polled = poll_report(id)
      status = polled.body[:poll_generate_report_response][:report_request_status][:status] rescue nil
      raise "Report status: Error for ID: #{id}. TrackingId: #{polled.header[:tracking_id]}" if status == "Error"
      status == "Success"
    end

    def report_url(id)
      poll_report(id).body[:poll_generate_report_response][:report_request_status][:report_download_url] rescue nil
    end

    def report_body(id)
      @client.download(report_url(id))
    end

    private

      def generate_report_message(options)
        period = options[:period]
        report_type = options[:report_type]
        account_id = @account_id.nil? ? nil : { 'arr:long' => @account_id }
        {
          ns('ReportRequest') => {
            ns('Format') => options[:format],
            ns('Language') => 'English',
            ns('ReportName') => options[:report_name],
            ns('ReturnOnlyCompleteData') => false,
            ns('Aggregation') => options[:aggregation],
            ns('Columns') => {
              ns("#{report_type}ReportColumn") => options[:columns]
            },
            ns('Scope') => {
              ns('AccountIds') => account_id,
              ns('AdGroups') => nil,
              ns('Campaigns') => nil
            },
            ns("Time") => {
              # apparently order is important, and end date has to be before start date
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
          },
          :attributes! => {
            ns("ReportRequest") => {
              "xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance",
              "i:type" => ns("#{report_type}ReportRequest")
            }
          }
        }
      end

      def submit_generate_report(options)
        message = generate_report_message(options)
        response = @client.call(:submit_generate_report, message)
        response.body[:submit_generate_report_response][:report_request_id]
      end

      def default_options(report_settings)
        { format: report_settings[:report_format],
          columns: report_settings[:columns],
          aggregation: report_settings[:aggregation],
          report_type: report_settings[:report_type],
          report_name: report_settings[:report_name]
        }
      end

      def poll_report(id)
        @client.call(:poll_generate_report, {
          ns("ReportRequestId") => id,
          :attributes! => {
            ns("ReportRequestId") => {
              "xsi:nil" => false
            }
          }
        })
      end

      def ns(str)
        "tns:#{str}"
      end
  end
end
