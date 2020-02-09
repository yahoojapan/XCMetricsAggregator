require 'spec_helper'
require 'json'

RSpec.describe "XCMetricsAggregator::CategoryService" do
    pathes = ["/foo/foo/app.bundle_id.foo", "/foo/foo/app.bundle_id.bar",  "/foo/foo/app.bundle_id.foobar"]

    describe "calling devicefamilies" do
      it "returns all devicefamilies" do
        json_str = File.read "./spec/fixture/example_app.json"
        json = JSON.parse json_str
        service = XcMetricsAggregator::DevicesService.new "bundle_id", json
        devicefamilies = service.devicefamilies
        expect(devicefamilies.count).to eq 1
        expect(devicefamilies[0].is_represented).to eq "true"
        expect(devicefamilies[0].devices.count).to eq 1
        expect(devicefamilies[0].display_name).to eq "iPhone (All)"
        expect(devicefamilies[0].identifier).to eq "all_iphones"
      end
    end

    describe "calling structure" do
        it "returns table" do
          json_str = File.read "./spec/fixture/example_app.json"
          json = JSON.parse json_str
          service = XcMetricsAggregator::DevicesService.new "bundle_id", json
          structure = service.structure
          expect(structure.title).to eq "bundle_id"
          expect(structure.rows).to eq [["iPhone (All)", "iPhone 5s", "iPhone6,1"]]
          expect(structure.headings).to eq ["kind", "device", "id"]
        end
      end

      describe "calling get_device" do
        it "returns device with identifier" do
          json_str = File.read "./spec/fixture/example_app.json"
          json = JSON.parse json_str
          service = XcMetricsAggregator::DevicesService.new "bundle_id", json
          device = service.get_device "iPhone6,1"
          expect(device.display_name).to eq "iPhone 5s"
          expect(device.is_represented).to eq "false"
          expect(device.identifier).to eq "iPhone6,1"
        end
      end
end