# Bing Ads Reports

## Installation

    gem install bing-ads-reporting

## Usage

Initialise service

    service = BingAdsReporting::Service.new({developerToken: '', applicationToken: '', password: '', username: '', :accountId: '', customerId: ''})

Create report and get it's ID

    period = Datebox::Period.new('2013-07-01', '2013-07-03')
    id = service.generate_report({report_type: 'KeywordPerformance',
                                  report_format: 'Tsv',
                                  aggregation: 'Daily',
                                  aggregation_period: 'ReportAggregation::Daily',
                                  columns: %w[AccountId AccountName CampaignId CampaignName AdGroupId AdGroupName KeywordId Keyword DestinationUrl DeliveredMatchType AverageCpc CurrentMaxCpc AdDistribution CurrencyCode Impressions Clicks Ctr CostPerConversion Spend AveragePosition TimePeriod CampaignStatus AdGroupStatus DeviceType]},
                                 {period: period})

Get report URL for download by report ID if it's ready

    service.report_url(id) if service.report_ready?(id)

or get its content by ID (also once ready)

    service.report_body(id) if service.report_ready?(id)