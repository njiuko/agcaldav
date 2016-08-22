require 'spec_helper'

RSpec.describe SabredavClient::XmlRequestBuilder::Mkcalendar do
  let(:mkcalendar) { described_class.new(displayname = "name", description = "description") }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/xml_request_builder/mkcalendar.xml') }

    it "returns a valid xml" do
      expect(mkcalendar.to_xml).to eq(expected_xml)
    end
  end
end
