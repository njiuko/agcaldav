require 'spec_helper'

describe SabredavClient::XmlRequestBuilder::ReportEventChanges do

  let(:report) { described_class.new(sync_token = "token-1234") }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/xml_request_builder/report_event_changes.xml') }

    it "returns a valid xml with displayname" do
      expect(report.to_xml).to eq(expected_xml)
    end
    end

end
