require 'spec_helper'

RSpec.describe SabredavClient::XmlRequestBuilder::PropfindOwner do

  let(:propfind) { described_class.new }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/xml_request_builder/propfind_owner.xml') }

    it "returns a valid xml" do
      expect(propfind.to_xml).to eq(expected_xml)
    end
  end
end
