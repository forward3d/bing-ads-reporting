module BingAdsReporting
  class BingSettings
    include BingHelper

    attr_reader :settings

    def initialize(settings)
      @settings = settings
    end

    def self.header(settings)
      new(settings).header
    end

    def header
      {
        ns('ApplicationToken') => settings[:applicationToken],
        ns('CustomerAccountId') => settings[:accountId],
        ns('CustomerId') => settings[:customerId],
        ns('DeveloperToken') => settings[:developerToken],
        ns('AuthenticationToken') => settings[:authenticationToken]
      }
    end
  end
end
