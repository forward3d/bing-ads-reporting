module BingAdsReporting
  class AuthenticationTokenExpired < Exception; end

  class Service

    def initialize(settings, logger = nil)
      @settings = settings
      @logger = logger || Logger.new($stdout)
    end

    def generate_report(report_settings, report_params)
      options = default_options(report_settings).merge(report_params)
      period = options[:period]
      report_type = options[:report_type]

      begin
        response = client.call(:submit_generate_report, message: {
          ns('ReportRequest') => {
            ns("Format") => options[:format],
            ns("Language") => "English",
            ns("ReportName") => options[:report_name],
            ns("ReturnOnlyCompleteData") => false,
            ns("Aggregation") => options[:aggregation],
            ns("Columns") => {
              ns("#{report_type}ReportColumn") => options[:columns]
            },
            ns("Scope") => {
              ns("AccountIds") => {
                'arr:long' => @settings[:account_id]
              }
            },
            ns("Time") => {
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
          },
          :attributes! => {
            ns("ReportRequest") => {
              "xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance",
              "i:type" => ns("#{report_type}ReportRequest")
            }
          }
        })

      rescue Savon::SOAPFault => e
        msg = 'unexpected error'
        err = e.to_hash[:fault][:detail][:ad_api_fault_detail][:errors][:ad_api_error][:error_code] rescue nil
        msg = e.to_hash[:fault][:detail][:ad_api_fault_detail][:errors][:ad_api_error][:message] if err
        if err.nil?
          err = e.to_hash[:fault][:detail][:api_fault_detail][:operation_errors][:operation_error][:error_code] rescue nil
          msg = e.to_hash[:fault][:detail][:api_fault_detail][:operation_errors][:operation_error][:message] if err
        end
        if err == 'AuthenticationTokenExpired'
          @logger.error err
          raise AuthenticationTokenExpired.new(msg)
        end
        @logger.error e.message
        @logger.error msg
        raise e
      end

      response.body[:submit_generate_report_response][:report_request_id]
    end

    def report_ready?(id)
      polled = poll_report(id)
      status = polled.body[:poll_generate_report_response][:report_request_status][:status] rescue nil
      raise "Report status: Error for ID: #{id}. TrackingId: #{polled.header[:tracking_id]}" if status == "Error"
      status == "Success"
    end

    def report_url(id)
      download_url = poll_report(id).body[:poll_generate_report_response][:report_request_status][:report_download_url] rescue nil
    end

    def report_body(id)
      download(report_url(id))
    end

    private

      def default_options(report_settings)
        { format: report_settings[:report_format],
          columns: report_settings[:columns],
          aggregation: report_settings[:aggregation],
          report_type: report_settings[:report_type],
          report_name: report_settings[:report_name]
        }
      end

      def poll_report(id)
        client.call(:poll_generate_report, message: {
          ns("ReportRequestId") => id,
          :attributes! => {
            ns("ReportRequestId") => {
              "xsi:nil" => false
            }
          }
        })
      end

      def download(url)
        @logger.debug "Downloading Bing report from: #{url}"
        curl = Curl::Easy.new(url)
        curl.perform
        curl.body_str
      end

      def client
        if @settings[:username] && @settings[:password]
          header = {
            ns('ApplicationToken') => @settings[:application_token],
            ns('CustomerAccountId') => @settings[:account_id],
            ns('CustomerId') => @settings[:customer_id],
            ns('DeveloperToken') => @settings[:developer_token],
            ns('UserName') => @settings[:username],
            ns('Password') => @settings[:password]
          }
        else
          header = {
            ns('ApplicationToken') => @settings[:application_token],
            ns('CustomerAccountId') => @settings[:account_id],
            ns('CustomerId') => @settings[:customer_id],
            ns('DeveloperToken') => @settings[:developer_token],
            ns('AuthenticationToken') => @settings[:authentication_token]
          }
        end
        Savon.client({
          wsdl: "https://api.bingads.microsoft.com/Api/Advertiser/Reporting/V9/ReportingService.svc?wsdl",
          namespaces: {"xmlns:arr" => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'},
          soap_header: header,
          log_level: @settings[:log_level] || :info,
          pretty_print_xml: true
        })
      end

      def ns(str)
        "tns:#{str}"
      end

  end
end
