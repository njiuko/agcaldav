require 'spec_helper'

RSpec.describe AgCalDAV::Request::PROPFINDCalendar do
  let(:propfind) { described_class.new(properties: [:displayname, :getctag, :sync_token]) }

  describe "#to_xml" do
    let(:expected_xml) { File.read('spec/fixtures/propfind_calendar/all_properties.xml') }

    it "returns a valid xml" do
      expect(propfind.to_xml).to eq(expected_xml)
    end
  end
end

