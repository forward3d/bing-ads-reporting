module BingAdsReporting
  module AbstractMethods
    private

    def wdsl
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def failed_status
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def success_status
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def report_operation(_option)
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def generate_report_message(_options)
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def poll_operation
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def generate_poll_message(_report_id)
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def get_report_id(_body, _options)
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def get_status(_body)
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end

    def get_download_url(_body)
      raise NotImplementedError, "subclass did not define ##{__method__}"
    end
  end
end
