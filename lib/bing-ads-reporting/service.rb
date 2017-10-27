module BingAdsReporting
  class AuthenticationTokenExpired < Exception; end
  
  class Service
    SUCCESS = 'Success'

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
            ns("ReturnOnlyCompleteData") => 'false',

            ns("Aggregation") => options[:aggregation],
            ns("Columns") => {
              ns("#{report_type}ReportColumn") => options[:columns]
            },
            ns("Scope") => {
              ns("AccountIds") => {
                'arr:long' => @settings[:accountId]
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
          :attributes! => {ns("ReportRequest") => {
                                                   "i:type" => ns("#{report_type}ReportRequest"),
                                                   "i:nil" => 'false'
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
      status == SUCCESS
    end
    
    # returns nil if there is no data
    def report_body(id)
      download(report_url(id))
    end
  
    private

      def report_url(id)
        polled = poll_report(id)
        status = polled.body[:poll_generate_report_response][:report_request_status][:status] rescue nil
        download_url = polled.body[:poll_generate_report_response][:report_request_status][:report_download_url] rescue nil
        return nil if download_url.nil? && status == SUCCESS
        raise "Report URL is not available for report id #{id}" unless download_url
        download_url
      end
  
      def default_options(report_settings)
        { format: report_settings[:report_format],
          columns: report_settings[:columns],
          aggregation: report_settings[:aggregation],
          report_type: report_settings[:report_type],
          report_name: "MyReport" }
      end
      
      def poll_report(id)
        begin
          client.call(:poll_generate_report, message: {
            ns("ReportRequestId") => id,
          })
        rescue Savon::SOAPFault => e
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
        end
      end

      def download(url)
        return unless url
        @logger.debug "Downloading Bing report from: #{url}"
        curl = Curl::Easy.new(url)
        curl.perform
        curl.body_str
      end

      def client
        if @settings[:username] && @settings[:password]
          header = {ns('ApplicationToken') => @settings[:applicationToken],
                                              ns('CustomerAccountId') => @settings[:accountId],
                                              ns('CustomerId') => @settings[:customerId],
                                              ns('DeveloperToken') => @settings[:developerToken],
                                              ns('UserName') => @settings[:username],
                                              ns('Password') => @settings[:password] }
        else
          header = {ns('ApplicationToken') => @settings[:applicationToken],
                                              ns('CustomerAccountId') => @settings[:accountId],
                                              ns('CustomerId') => @settings[:customerId],
                                              ns('DeveloperToken') => @settings[:developerToken],
                                              ns('AuthenticationToken') => @settings[:authenticationToken] }
        end
        Savon.client({
                      wsdl: "https://reporting.api.bingads.microsoft.com/Api/Advertiser/Reporting/V11/ReportingService.svc?singleWsdl",
                      log_level: :info,
                      namespaces: { "xmlns:arr" => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays',
                                    "xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance" },
                      soap_header: header
                      })
                      # .merge({pretty_print_xml: true, log_level: :debug, log: true, logger: @logger})) # for more logging
      end

      def ns(str)
        "tns:#{str}"
      end

  end
end