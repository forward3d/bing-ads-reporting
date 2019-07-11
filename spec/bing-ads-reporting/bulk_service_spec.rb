require 'spec_helper'
require 'savon'
require 'nori'
require 'datebox'
require 'curl'

describe BingAdsReporting::BulkService do
  let(:dev_token)   { '0000000123DF' }
  let(:app_token)   { '0000000SD313' }
  let(:auth_token)  { 'MS12399031jj' }
  let(:account_id)  { '123458' }
  let(:customer_id) { '6667434' }
  let(:report_id)   { '68818318726' }
  let(:period)      { Datebox::Period.new('2019-06-28', '2019-06-30') }
  let(:nori)        { Nori.new(strip_namespaces: true, convert_tags_to: ->(tag) { tag.snakecase.to_sym }) }
  let(:service)     { described_class.new(account_settings) }
  let(:encoded_response) { nori.parse(xml_response)[:envelope][:body] }
  let(:response_double)  { instance_double('Savon::Response', header: {}, body: encoded_response) }
  let(:report_type) { 'GetBulkDownloadStatus' }
  let(:account_settings) do
    {
      developerToken: dev_token,
      applicationToken: app_token,
      authenticationToken: auth_token,
      accountId: account_id,
      customerId: customer_id,
      report_type: report_type,
      report_format: 'Tsv',
      data_scope: 'EntityData',
      download_entities: ['Keywords']
    }
  end

  before do
    allow_any_instance_of(Savon::Client).to receive(:call) { response_double }
  end

  describe '#generate_report' do
    subject(:report_test) { service.generate_report(account_settings, period: period) }

    context 'when requesting report submission' do
      let(:xml_response) do
        BingSoapHelper.bulk_service_report_submit
      end

      it { expect(report_test).to eq(report_id) }
    end
  end

  describe '#report_ready?' do
    let(:id) { '123123' }

    subject(:report_test) { service.report_ready?(id) }

    context 'when the report is ready' do
      let(:xml_response) { BingSoapHelper.poll_bulk_service_completed }

      it { is_expected.to be true }
    end

    context 'when the report is not ready' do
      let(:xml_response) { BingSoapHelper.poll_bulk_service_not_complete }

      it { is_expected.to be false }
    end

    context 'when the report fails' do
      let(:xml_response) { BingSoapHelper.poll_bulk_service_error }

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
      let(:xml_response) { BingSoapHelper.poll_bulk_service_completed }

      it { is_expected.to eq('REPORT_DATA') }
    end

    context 'when report is not ready' do
      let(:xml_response) { BingSoapHelper.poll_bulk_service_not_complete }

      it { expect { report_body }.to raise_exception(RuntimeError) }
    end
  end
end
