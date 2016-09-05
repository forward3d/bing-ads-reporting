module BingAdsReporting
  class Client
    API_CALL_RETRY_COUNT = 3

    def initialize(settings, logger)
      if settings[:username] && settings[:password]
        header = {
          ns('ApplicationToken') => settings[:application_token],
          ns('CustomerAccountId') => settings[:account_id],
          ns('CustomerId') => settings[:customer_id],
          ns('DeveloperToken') => settings[:developer_token],
          ns('UserName') => settings[:username],
          ns('Password') => settings[:password]
        }
      else
        header = {
          ns('ApplicationToken') => settings[:application_token],
          ns('CustomerAccountId') => settings[:account_id],
          ns('CustomerId') => settings[:customer_id],
          ns('DeveloperToken') => settings[:developer_token],
          ns('AuthenticationToken') => settings[:authentication_token]
        }
      end
      @logger = logger
      @soap_client = Savon.client({
        wsdl: "https://api.bingads.microsoft.com/Api/Advertiser/Reporting/V9/ReportingService.svc?wsdl",
        namespaces: {"xmlns:arr" => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'},
        soap_header: header,
        log_level: settings[:log_level] || :info,
        pretty_print_xml: true
      })
    end

    def call(service, message, retry_count = API_CALL_RETRY_COUNT)
      1.upto(retry_count) do |retry_index|
        begin
          response = @soap_client.call(service, message: message)
          return response
        rescue Savon::SOAPFault => error
          next if retry_index <= retry_count
          handle_soap_fault(error)
        end
      end
    end

    def download(url)
      @logger.info "Downloading Bing material from: #{url}"
      curl = Curl::Easy.new(url)
      curl.perform
      curl.body_str
    end

    private

    def handle_soap_fault(error)
      msg = 'unexpected error'
      err = error.to_hash[:fault][:detail][:ad_api_fault_detail][:errors][:ad_api_error][:error_code] rescue nil
      msg = error.to_hash[:fault][:detail][:ad_api_fault_detail][:errors][:ad_api_error][:message] if err
      if err.nil?
        err = error.to_hash[:fault][:detail][:api_fault_detail][:operation_errors][:operation_error][:error_code] rescue nil
        msg = error.to_hash[:fault][:detail][:api_fault_detail][:operation_errors][:operation_error][:message] if err
      end
      if err == 'AuthenticationTokenExpired'
        @logger.error err
        raise TokenExpired, msg
      end
      @logger.error error.http.code
      @logger.error error.message
      @logger.error msg
      raise ClientDataError, "HTTP error code: #{error.http.code}\n#{error.message}"
    end
  end
end
