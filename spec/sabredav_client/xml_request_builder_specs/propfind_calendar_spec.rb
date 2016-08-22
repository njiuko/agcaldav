require 'spec_helper'

RSpec.describe SabredavClient::XmlRequestBuilder::PROPFINDCalendar do
  let(:propfind) { described_class.new(properties: [:displayname, :getctag, :sync_token]) }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/propfind_calendar/all_properties.xml') }

    it "returns a valid xml" do
      expect(propfind.to_xml).to eq(expected_xml)
    end

    context "error" do
      let(:propfind) { described_class.new(properties: [:displayname, :etag, :sync_token]) }

      it "raises an error if the not supported properties are selected" do
        expect {
          propfind.to_xml
        }.to raise_error(SabredavClient::Errors::PropertyNotSupportedError)
      end

    end
  end
end
