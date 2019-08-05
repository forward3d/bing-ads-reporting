# Bing Ads Reports

## Installation

    gem install bing-ads-reporting

## Usage

### Initializing service.

#### All Reporting Service - [Bing Ads Reference for Reporting Service](https://docs.microsoft.com/en-us/advertising/reporting-service/reporting-service-reference?view=bingads-12)

```ruby
service = BingAdsReporting::ReportingService.new({
  developerToken: '',
  applicationToken: '',
  authenticationToken: '',
  :accountId: '',
  customerId: ''})
```

#### Bulk Service - [Bing Ads API reference for Bulk Service](https://docs.microsoft.com/en-us/advertising/reporting-service/reporting-service-operations?view=bingads-12)

```ruby
service = BingAdsReporting::BulkService.new({
  developerToken: '',
  applicationToken: '',
  authenticationToken: '',
  :accountId: '',
  customerId: ''
})
```

#### Insight Service(actual AdInsight Serive) - [Bing Ads API reference for Bulk Service](https://docs.microsoft.com/en-us/advertising/ad-insight-service/ad-insight-service-reference?view=bingads-13)

```ruby
service = BingAdsReporting::InsightService.new(auth_settings, logger, request_class)
```

##### Request Class example

For which report in AdInsightService API, which one has different SOAP request.

Bellow an example of the request for [Auction Insight report](https://docs.microsoft.com/en-us/advertising/ad-insight-service/getauctioninsightdata?view=bingads-13#request-soap).

```ruby
class AuctionInsightRequest
  attr_reader :period, :options

  def initialize(period, options)
    @period = period
    @options = options
  end

  def self.message(period, options)
    new(period, options).message
  end

  def message
    {
      'EntityType' => options[:entity_type],
      'SearchParameters' => {
        'SearchParameter' => {
          'EndDate' => {
            'Day' => '10',
            'Month' => '02',
            'Year' => '2018'
          },
          'StartDate' => {
            'Day' => '10',
            'Month' => '01',
            'Year' => '2018'
          },
          '@i:type' => 'tns:DateRangeSearchParameter'
        }
      },
      '@xsi:type' => 'tns:DateRangeSearchParameter'
    }
  end
end
```

#### AdInsight Service(DEPRECATED)

Use `ReportingService` instead.

```ruby
service = BingAdsReporting::AdInsightService.new({
  developerToken: '',
  applicationToken: '',
  authenticationToken: '',
  :accountId: '',
  customerId: ''
})
```

## Create report and get it's ID

### Ad Reporting Service

```ruby
period = Datebox::Period.new('2013-07-01', '2013-07-03')
id = service.generate_report({report_type: 'KeywordPerformance',
                              report_format: 'Tsv',
                              aggregation: 'Daily',
                              aggregation_period: 'ReportAggregation::Daily',
                              columns: %w[AccountId AccountName CampaignId CampaignName AdGroupId AdGroupName KeywordId Keyword DestinationUrl DeliveredMatchType AverageCpc CurrentMaxCpc AdDistribution CurrencyCode Impressions Clicks Ctr CostPerConversion Spend AveragePosition TimePeriod CampaignStatus AdGroupStatus DeviceType]},
                              {period: period})
```

### Bulk Service

```ruby
id = service.generate_report({report_type: 'DownloadCampaignsByAccountIds'
                              report_format: 'Tsv',
                              data_scope: 'EntityData'
                              download_entities: ['Keywords']},
                              {})
```

### Get Report

Get report URL for download by report ID if it's ready

```ruby
service.report_url(id) if service.report_ready?(id)
```

or get its content by ID (also once ready)

```ruby
service.report_body(id) if service.report_ready?(id)
```

## InsightService

### Get Auction Insight Results

```ruby
result = service.generate_report({report_type: AuctionInsightData, entity_type: 'Account'})
```

### Get Auction Insight Results for Keywords

```ruby
result = service.generate_report({report_type: AuctionInsightData, entity_type: 'Account', entity_ids: [1, 2, 3]})
```
