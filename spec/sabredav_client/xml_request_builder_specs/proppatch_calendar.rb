require 'spec_helper'

RSpec.describe SabredavClient::XmlRequestBuilder::ProppatchCalendar do

  let(:proppatch) { described_class.new(displayname = "name", description = "description") }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/xml_request_builder/proppatch_calendar.xml') }

    it "returns a valid xml" do
      expect(proppatch.to_xml).to eq(expected_xml)
    end

  end
end
