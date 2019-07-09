require 'spec_helper'
require 'savon'
require 'nori'
require 'datebox'
require 'curl'

describe BingAdsReporting::AdInsightService do
  let(:dev_token)   { '0000000123DF' }
  let(:app_token)   { '0000000SD313' }
  let(:auth_token)  { 'MS12399031jj' }
  let(:account_id)  { '123458' }
  let(:customer_id) { '6667434' }
  let(:report_id)   { '30000003027034680' }
  let(:period)      { Datebox::Period.new('2019-06-28', '2019-06-30') }
  let(:nori)        { Nori.new(strip_namespaces: true, convert_tags_to: ->(tag) { tag.snakecase.to_sym }) }
  let(:service)     { described_class.new(account_settings) }
  let(:encoded_response) { nori.parse(xml_response)[:envelope][:body] }
  let(:response_double)  { instance_double('Savon::Response', header: {}, body: encoded_response) }
  let(:account_settings) do
    {
      developerToken: dev_token,
      applicationToken: app_token,
      authenticationToken: auth_token,
      accountId: account_id,
      customerId: customer_id
    }
  end

  before do
    allow_any_instance_of(Savon::Client).to receive(:call) { response_double }
  end

  describe '#generate_report' do
    subject(:report_test) { service.generate_report(account_settings, period: period) }

    context 'when requesting report submission' do
      let(:xml_response) do
        '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
          <s:Header>
            <h:TrackingId xmlns:h="https://bingads.microsoft.com/Reporting/v12">
              d012a57e-8d84-456f-9562-b223a6d6a348
            </h:TrackingId>
          </s:Header>
          <s:Body>
            <SubmitGenerateReportResponse xmlns="https://bingads.microsoft.com/Reporting/v12">
              <ReportRequestId>30000003027034680</ReportRequestId>
            </SubmitGenerateReportResponse>
          </s:Body>
        </s:Envelope>'
      end

      it { expect(report_test).to eq(report_id) }
    end

    context 'when request error happen' do
      let(:error_hash) do
        {
          fault: {
            faultcode: 's:Server',
          faultstring: 'Invalid client data. Check the SOAP fault details for more information',
          detail: {
            api_fault_detail: {
              :tracking_id => 'c782ddaa-b735-404e-8111-b61f1776ae71',
              :batch_errors => nil,
              :operation_errors => {
                operation_error: {
                  code: '2010',
                  details: nil,
                  error_code: 'InvalidCustomDateRangeEnd',
                  message: 'The specified report time contains an invalid custom date range end.
                   Please submit a report request with valid start and end dates for the custom date range.'
                }
              },
                  :@xmlns => 'https://bingads.microsoft.com/Reporting/v12',
                  :"@xmlns:i" => 'http://www.w3.org/2001/XMLSchema-instance'
            }
          }
          }
        }
      end
      let(:response_double) { instance_double('Savon::Response', body: '') }
      let(:savon_exception) do
        Savon::SOAPFault.new(response_double, nori)
      end

      before do
        allow_any_instance_of(Savon::SOAPFault).to receive(:to_s).and_return('Error Message')
        allow_any_instance_of(Savon::SOAPFault).to receive(:to_hash) { error_hash }
        allow_any_instance_of(Savon::Client).to receive(:call).and_raise(savon_exception)
      end

      it { expect { report_test }.to raise_exception(Savon::SOAPFault) }
    end

    context 'when the token is expired' do
      let(:error_hash) do
        {
          fault: {
            faultcode: 's:Server',
            faultstring: 'Invalid client data. Check the SOAP fault details for more information',
            detail: {
              api_fault_detail: {
                :tracking_id => 'c782ddaa-b735-404e-8111-b61f1776ae71',
                :batch_errors => nil,
                :operation_errors => {
                  operation_error: {
                    code: '2010',
                    details: nil,
                    error_code: 'AuthenticationTokenExpired',
                    message: 'Authentication token is expired.'
                  }
                },
                :@xmlns => 'https://bingads.microsoft.com/Reporting/v12',
                :"@xmlns:i" => 'http://www.w3.org/2001/XMLSchema-instance'
              }
            }
          }
        }
      end
      let(:response_double) { instance_double('Savon::Response', body: '') }
      let(:savon_exception) do
        Savon::SOAPFault.new(response_double, nori)
      end

      before do
        allow_any_instance_of(Savon::SOAPFault).to receive(:to_s).and_return('Error Message')
        allow_any_instance_of(Savon::SOAPFault).to receive(:to_hash) { error_hash }
        allow_any_instance_of(Savon::Client).to receive(:call).and_raise(savon_exception)
      end

      it do
        expect { report_test }.to(
          raise_exception(
            BingAdsReporting::AuthenticationTokenExpired,
            'Authentication token is expired.'
          )
        )
      end
    end
  end

  describe '#report_ready?' do
    let(:id) { '123123' }

    subject(:report_test) { service.report_ready?(id) }

    context 'when the report is ready' do
      let(:xml_response) { BingSoapHelper.poll_report_ready }

      it { is_expected.to be true }
    end

    context 'when the report fails' do
      let(:xml_response) { BingSoapHelper.poll_report_error }

      it { expect { report_test }.to raise_exception(RuntimeError) }
    end
  end

  describe '#report_body' do
    subject(:report_body) { service.report_body(report_id) }

    before do
      allow_any_instance_of(Curl::Easy).to receive(:perform).and_return(true)
      allow_any_instance_of(Curl::Easy).to receive(:body_str).and_return('REPORT_DATA')
    end

    context 'when report is ready' do
      let(:xml_response) { BingSoapHelper.poll_report_ready }

      it { is_expected.to eq('REPORT_DATA') }
    end

    context 'when report is not ready' do
      let(:xml_response) { BingSoapHelper.poll_report_without_url }

      it { is_expected.to eq(nil) }
    end

    context 'when report is not ready' do
      let(:xml_response) { BingSoapHelper.poll_report_not_ready }

      it { expect { report_body }.to raise_exception(RuntimeError) }
    end

    context 'when report download fails' do
      let(:xml_response) { BingSoapHelper.poll_report_error }

      it { expect { report_body }.to raise_exception(RuntimeError) }
    end
  end
end
