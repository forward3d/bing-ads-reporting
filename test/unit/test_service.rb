require_relative "../test_helper"
require 'curb'
require 'datebox'

class TestReport < Test::Unit::TestCase

  def setup
    yml = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)), "credentials.yml")) # create this if you want to test!
    @service = BingAdsReporting::Service.new(yml)
    @id_to_check = "1109867403" # set for tests to pass
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
    puts @service.report_ready?(@id_to_check)
  end

  def test_gets_report_url
    puts @service.report_url(@id_to_check)
  end
  
  def test_gets_report
    puts @service.report_body(@id_to_check)
  end
  
end
