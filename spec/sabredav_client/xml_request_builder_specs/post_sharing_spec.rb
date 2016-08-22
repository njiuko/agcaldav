require 'spec_helper'

RSpec.describe SabredavClient::XmlRequestBuilder::PostSharing do
  let(:post) { described_class.new(adds = ["add1@test.de", "add2@test.de"],
     summary = "title", common_name = "common_name", privilege = "read-write",
     removes = ["remove@test.de"]) }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/xml_request_builder/post_sharing.xml') }

    it "returns a valid xml" do
      expect(post.to_xml).to eq(expected_xml)
    end
  end
end
