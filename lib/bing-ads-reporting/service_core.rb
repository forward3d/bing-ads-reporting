require 'savon'
require_relative 'abstract_methods'
require_relative 'bing_settings'

module BingAdsReporting
  class AuthenticationTokenExpired < StandardError; end
  class AuthenticationViaOAuthIsRequired < StandardError; end

  class ServiceCore
    include BingAdsReporting::AbstractMethods
    def initialize(settings, logger = nil)
      @settings = settings
      @logger = logger || Logger.new($stdout)
    end

    def generate_report(report_settings, report_params)
      options = default_options(report_settings).merge(report_params)
      begin
        response = client.call(report_operation(options), message: generate_report_message(options))
      rescue Savon::SOAPFault => e
        handle_error(e)
        @logger.error e.message
        raise e
      end

      get_report_id(response.body, options)
    end

    # returns nil if there is no data
    def report_body(report_id)
      download_url = report_url(report_id)
      download(download_url)
    end

    def report_ready?(report_id)
      polled = poll_report(report_id)
      status = get_status(polled.body)
      raise "Report status: Error for ID: #{report_id}. TrackingId: #{polled.header[:tracking_id]}" if status == failed_status

      status == success_status
    end

    private

    def default_options(report_settings)
      { report_name: 'MyReport' }.merge(report_settings.map { |k, v| [k.to_sym, v] }.to_h)
    end

    def poll_report(report_id)
      client.call(poll_operation, message: generate_poll_message(report_id))
    rescue Savon::SOAPFault => e
      handle_error(e)
    end

    def handle_error(exception_obj)
      err = get_error_code(exception_obj)
      msg = exception_obj.to_hash[:fault][:detail][:ad_api_fault_detail][:errors][:ad_api_error][:message] if err

      if err.nil?
        err = get_operation_error_code(exception_obj)
        msg = exception_obj.to_hash[:fault][:detail][:api_fault_detail][:operation_errors][:operation_error][:message] if err
      end

      raise_error_if_token_expired(err, msg)
    end

    def token_expired?(err)
      err == 'AuthenticationTokenExpired'
    end

    def get_error_code(exception_obj)
      exception_obj.to_hash[:fault][:detail][:ad_api_fault_detail][:errors][:ad_api_error][:error_code]
    rescue StandardError
      nil
    end

    def get_operation_error_code(exception_obj)
      exception_obj.to_hash[:fault][:detail][:api_fault_detail][:operation_errors][:operation_error][:error_code]
    rescue StandardError
      nil
    end

    def raise_error_if_token_expired(err, msg)
      @logger.error(err) if token_expired?(err)
      raise AuthenticationTokenExpired, msg if token_expired?(err)
    end

    def report_url(report_id)
      polled = poll_report(report_id)
      status = get_status(polled.body)
      download_url = get_download_url(polled.body)
      return nil if download_url.nil? && status == success_status
      raise "Report URL is not available for report id #{report_id}" unless download_url

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
      exception_msg = 'Microsoft Account Authentication via OAuth is Required'
      raise AuthenticationViaOAuthIsRequired, exception_msg if user_and_pass?

      Savon.client(client_config)
    end

    def user_and_pass?
      @settings[:username] && @settings[:password]
    end

    def client_config
      header = BingAdsReporting::BingSettings.header(@settings)

      {
        wsdl: wdsl,
        log_level: :info,
        namespaces: { 'xmlns:arr' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays',
                      'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance' },
        soap_header: header
      }
    end

    def ns(str)
      "tns:#{str}"
    end
  end
end
