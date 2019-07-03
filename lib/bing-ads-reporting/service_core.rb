require 'savon'

module BingAdsReporting
  class AuthenticationTokenExpired < StandardError; end
  class AuthenticationViaOAuthIsRequired < StandardError; end

  class ServiceCore

    def initialize(settings, logger = nil)
      @settings = settings
      @logger = logger || Logger.new($stdout)
    end

    def generate_report(report_settings, report_params)
      options = default_options(report_settings).merge(report_params)
      begin
        response = client.call(report_operation(options), message: generate_report_message(options))
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

      get_report_id(response.body, options)
    end

    # returns nil if there is no data
    def report_body(id)
      download(report_url(id))
    end

    def report_ready?(id)
      polled = poll_report(id)
      status = get_status(polled.body)
      raise "Report status: Error for ID: #{id}. TrackingId: #{polled.header[:tracking_id]}" if status == failed_status
      status == success_status
    end

    private

    def wdsl
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def failed_status
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def success_status
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def report_operation(option)
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def generate_report_message(options)
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def poll_operation
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def generate_poll_message(id)
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def get_report_id(body, options)
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def get_status(body)
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def get_download_url(body)
      raise NotImplementedError, "subclass did not define ##{__method__.to_s}"
    end

    def default_options(report_settings)
      ({ report_name: 'MyReport' }).merge(report_settings.map { |k,v| [k.to_sym, v] }.to_h)
    end

    def poll_report(id)
      begin
        client.call(poll_operation, message: generate_poll_message(id))
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

    def report_url(id)
      polled = poll_report(id)
      status = get_status(polled.body)
      download_url = get_download_url(polled.body)
      return nil if download_url.nil? && status == success_status
      raise "Report URL is not available for report id #{id}" unless download_url
      download_url
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
        raise AuthenticationViaOAuthIsRequired, 'Microsoft Account Authentication via OAuth is Required'
      else
        header = {ns('ApplicationToken') => @settings[:applicationToken],
                  ns('CustomerAccountId') => @settings[:accountId],
                  ns('CustomerId') => @settings[:customerId],
                  ns('DeveloperToken') => @settings[:developerToken],
                  ns('AuthenticationToken') => @settings[:authenticationToken] }
      end
      Savon.client({
                    wsdl: wdsl,
                    log_level: :info,
                    namespaces: { 'xmlns:arr' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays',
                                  'xmlns:i' => "http://www.w3.org/2001/XMLSchema-instance" },
                    soap_header: header
                    })
    end


    def ns(str)
      "tns:#{str}"
    end

  end
end
