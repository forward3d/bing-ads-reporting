module BingAdsReporting
  module SoapErrorHelper
    def self.fault_error_code(fault_detail)
      get_error_code(fault_detail) || get_operation_error_code(fault_detail)
    end

    def self.fault_error_msg(fault_detail)
      get_error_msg(fault_detail) || get_operation_error_msg(fault_detail)
    end

    def self.get_error_msg(fault_detail)
      fault_detail[:ad_api_fault_detail][:errors][:ad_api_error][:message]
    rescue StandardError
      nil
    end

    def self.get_operation_error_msg(fault_detail)
      fault_detail[:api_fault_detail][:operation_errors][:operation_error][:message]
    rescue StandardError
      nil
    end

    def self.get_error_code(fault_detail)
      fault_detail[:ad_api_fault_detail][:errors][:ad_api_error][:error_code]
    rescue StandardError
      nil
    end

    def self.get_operation_error_code(fault_detail)
      fault_detail[:api_fault_detail][:operation_errors][:operation_error][:error_code]
    rescue StandardError
      nil
    end
  end
end
