require 'savon'
require_relative 'abstract_methods'
require_relative 'downloader'

module BingAdsReporting
  class AuthenticationTokenExpired < StandardError; end
  class AuthenticationViaOAuthIsRequired < StandardError; end

  class ServiceCore
    include AbstractMethods
    include BingHelper

    def initialize(settings, logger = nil)
      @settings = settings
      @logger = logger
    end

    def generate_report(report_settings, report_params)
      options = default_options(report_settings).merge(report_params)
      response = call_operation(options)

      get_report_id(response.body, options)
    end

    # returns nil if there is no data
    def report_body(report_id)
      download_url = report_url(report_id)
      return unless download_url

      Downloader.fetch_report(download_url)
    end

    def report_ready?(report_id)
      polled = poll_report(report_id)
      status = get_status(polled.body)
      raise "Report status: Error for ID: #{report_id}. TrackingId: #{polled.header[:tracking_id]}" if status == failed_status

      status == success_status
    end

    private

    def call_operation(options)
      client.call(report_operation(options), message: generate_report_message(options))
    rescue Savon::SOAPFault => e
      handle_error(e)
      logger.error e.message
      raise e
    end

    def default_options(report_settings)
      { report_name: 'MyReport' }.merge(report_settings.map { |k, v| [k.to_sym, v] }.to_h)
    end

    def poll_report(report_id)
      client.call(poll_operation, message: generate_poll_message(report_id))
    rescue Savon::SOAPFault => e
      handle_error(e)
    end

    def handle_error(exception_obj)
      fault_detail = exception_obj.to_hash[:fault][:detail]
      err = SoapErrorHelper.fault_error_code(fault_detail)
      msg = SoapErrorHelper.fault_error_msg(fault_detail)

      raise_error_if_token_expired(err, msg)
    end

    def token_expired?(err)
      err == 'AuthenticationTokenExpired'
    end

    def raise_error_if_token_expired(err, msg)
      if token_expired?(err)
        logger.error(err)
        raise AuthenticationTokenExpired, msg
      end

      nil
    end

    def report_url(report_id)
      info = report_info(report_id)
      download_url = info[:url]
      return if !download_url && info[:status] == success_status
      raise "Report URL is not available for report id #{report_id}" unless download_url

      download_url
    end

    def report_info(report_id)
      polled = poll_report(report_id)
      polled_body = polled.body

      { url: get_download_url(polled_body), status: get_status(polled_body) }
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
  end
end
