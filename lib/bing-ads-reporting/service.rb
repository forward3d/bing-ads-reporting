module BingAdsReporting
  class Service

    def initialize(settings)
      @settings = settings
    end
  
    def generate_report(report_settings, report_params)
      options = default_options(report_settings).merge(report_params)
      period = options[:period]
      report_type = options[:report_type]
    
      response = client.call(:submit_generate_report, message: {
        ns('ReportRequest') => {
          ns("Format") => options[:format],
          ns("Language") => "English",
          ns("ReportName") => options[:report_name],
          ns("ReturnOnlyCompleteData") => false,
          ns("Aggregation") => options[:aggregation],
          ns("Columns") => {
            ns("#{report_type}ReportColumn") => options[:columns]
          },
          ns("Scope") => {
            ns("AccountIds") => {
              'arr:long' => @settings[:accountId]
            }
          },
          ns("Time") => {
            # apparently order is important, and end date has to be before start date, wtf
            ns("CustomDateRangeEnd") => {
              ns("Day") => period.to.day,
              ns("Month") => period.to.month,
              ns("Year") => period.to.year
            },
            ns("CustomDateRangeStart") => {
              ns("Day") => period.from.day,
              ns("Month") => period.from.month,
              ns("Year") => period.from.year
            }
            # ns("PredefinedTime") => options[:time]
          }
        },
        :attributes! => {ns("ReportRequest") => {"xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance",
                                                 "i:type" => ns("#{report_type}ReportRequest")}
        }
      })
      
      response.body[:submit_generate_report_response][:report_request_id]
    end
  
    def report_ready?(id)
      status = poll_report(id).body[:poll_generate_report_response][:report_request_status][:status] rescue nil
      status == "Success"
    end
    
    def report_url(id)
      download_url = poll_report(id).body[:poll_generate_report_response][:report_request_status][:report_download_url] rescue nil
    end
    
    def report_body(id)
      download(report_url(id))
    end
  
    private
  
      def default_options(report_settings)
        { format: report_settings[:report_format],
          columns: report_settings[:columns],
          aggregation: report_settings[:aggregation],
          report_type: report_settings[:report_type],
          report_name: "MyReport" }
      end
      
      def poll_report(id)
        client.call(:poll_generate_report, message: {
          ns("ReportRequestId") => id,
          :attributes! => { ns("ReportRequestId") => {"xsi:nil" => false} }
        })
      end

      def download(url)
        puts %Q{Downloading Bing report from: #{url}}
        curl = Curl::Easy.new(url) do |c|
          c.use_ssl = 3
          c.ssl_version = 3
        end
        curl.perform
        curl.body_str
      end

      def client
        Savon.client({wsdl: "https://api.bingads.microsoft.com/Api/Advertiser/Reporting/V9/ReportingService.svc?wsdl",
                      log_level: :info,
                      namespaces: {"xmlns:arr" => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'},
                      soap_header: {ns('ApplicationToken') => @settings[:applicationToken],
                                    ns('CustomerAccountId') => @settings[:accountId],
                                    ns('CustomerId') => @settings[:customerId],
                                    ns('DeveloperToken') => @settings[:developerToken],
                                    ns('UserName') => @settings[:username],
                                    ns('Password') => @settings[:password] }
                      })
                      # .merge({pretty_print_xml: true, log_level: :debug}) # for more logging
      end

      def ns(str)
        "tns:#{str}"
      end
  
  end
end