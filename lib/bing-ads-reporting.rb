require 'logger'
require 'savon'
require_relative 'bing-ads-reporting/client'
require_relative 'bing-ads-reporting/service'
require_relative 'bing-ads-reporting/version'

module BingAdsReporting
  class TokenExpired < RuntimeException; end
  class ClientDataError < RuntimeException; end
end
