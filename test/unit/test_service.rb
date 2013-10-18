require_relative "../test_helper"
require 'datebox'

class TestReport < Test::Unit::TestCase

  def setup
    yml = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)), "credentials.yml")) # create this if you want to test!
    @service = BingAdsReporting::Service.new(yml)
  end
    

  def test_scheduling_report
    period = Datebox::Period.new(Date.today - 1, Date.today - 1)
    id = @service.generate_report({report_type: 'KeywordPerformance',
                                    report_format: 'Tsv',
                                    aggregation: 'Daily',
                                    aggregation_period: 'ReportAggregation::Daily',
                                    include_headers: 'false',
                                    columns: %w[AccountId AccountName CampaignId CampaignName AdGroupId AdGroupName KeywordId Keyword DestinationUrl MatchType AverageCpc CurrentMaxCpc AdDistribution CurrencyCode Impressions Clicks Ctr CostPerConversion Spend AveragePosition TimePeriod CampaignStatus AdGroupStatus DeviceType]},
                                   {period: period})
    p id
  end

  def test_gets_report_state
    puts @service.report_ready?("714786757")
  end

  def test_gets_report_url
    puts @service.report_url("714786757")
  end
  
  def test_gets_report
    puts @service.report_body("714786757")
  end
  
end
