require 'spec_helper'
require 'open3'

RSpec.describe "XCMetricsAggregator::Crawler" do
    describe "Crawler" do
      it "execute apple script file" do

        lib_dir = File.expand_path(".././lib/", __dir__)
        expect(Open3).to receive(:popen3).with("osascript #{lib_dir}/xcode_metrics_automation.applescript")

        XcMetricsAggregator::Crawler.execute
      end
    end
end