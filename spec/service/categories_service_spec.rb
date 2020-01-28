require 'spec_helper'
require 'json'

RSpec.describe "XCMetricsAggregator::CategoryService" do
    pathes = ["/foo/foo/app.bundle_id.foo", "/foo/foo/app.bundle_id.bar",  "/foo/foo/app.bundle_id.foobar"]

    describe "calling categories" do
      it "returns all products" do
        json_str = File.read "./spec/fixture/example_app.json"
        json = JSON.parse json_str
        service = XcMetricsAggregator::CategoriesService.new "bundle_id", json
        categories = service.categories
        expect(categories.count).to eq 1
        expect(categories[0].display_name).to eq "performance"
        expect(categories[0].sections.count).to eq 1
        expect(categories[0].identifier).to eq "performance"
      end
    end

    describe "calling get_dataset" do
      it "returns a dataset which has the specific section_name, device, percentile" do
        json_str = File.read "./spec/fixture/example_app.json"
        json = JSON.parse json_str
        service = XcMetricsAggregator::CategoriesService.new "bundle_id", json
        device_service = XcMetricsAggregator::DevicesService.new "bundle_id", json
        percentiles_service = XcMetricsAggregator::PercentilesService.new "bundle_id", json
        dataset = service.get_dataset("hangRate", device_service.get_device("iPhone6,1"), percentiles_service.percentiles.first)
        expect(dataset.points.count).to eq 1
        expect(dataset.filter_criteria.device).to eq "iPhone6,1"
        expect(dataset.filter_criteria.percentile).to eq "com.apple.dt.metrics.percentile.fifty"

      end
    end
end