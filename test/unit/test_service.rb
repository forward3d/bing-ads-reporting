require_relative "../test_helper"
require 'curb'
require 'datebox'

class TestReport < Test::Unit::TestCase

  def setup
    yml = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)), "credentials.yml")) # create this if you want to test!
    @service = BingAdsReporting::Service.new(yml)
    @id_to_check = "30000000980814567"
  end
    
  def test_scheduling_report
    period = Datebox::Period.new(Date.today - 1, Date.today - 1)
    id = @service.generate_report({report_type: 'KeywordPerformance',
                                    report_format: 'Tsv',
                                    aggregation: 'Daily',
                                    aggregation_period: 'ReportAggregation::Daily',
                                    include_headers: 'false',
                                    columns: %w[AccountId AccountName CampaignId CampaignName AdGroupId AdGroupName KeywordId Keyword DestinationUrl DeliveredMatchType AverageCpc CurrentMaxCpc AdDistribution CurrencyCode Impressions Clicks Ctr CostPerConversion Spend AveragePosition TimePeriod CampaignStatus AdGroupStatus DeviceType]},
                                   {period: period})
    puts "--- USE THE FOLLOWING ID IN TEST BELOW! SET: @id_to_check IN CODE ----"
    @id_to_check = id
    p id
  end

  def test_gets_report_state
    response = @service.report_ready?(@id_to_check)
    flunk("report_ready? should return true or false") unless [true, false].include?(response)
  end

  def test_gets_report_url
    url = @service.send :report_url, @id_to_check
    return if url.nil?
    assert_match(/^https\:.+bingads.+Download.+/, url)
  end

  def test_gets_report
    body = @service.report_body(@id_to_check)
    return if body.nil?
    assert_equal String, body.class
    assert body.size > 0
    assert_equal 'ASCII-8BIT', body.encoding.to_s
  end
  
end
