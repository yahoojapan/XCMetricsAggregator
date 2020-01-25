require 'spec_helper'


RSpec.describe "XCMetricsAggregator::CategoryService" do
    before do
        expect(Dir).to receive(:glob).and_return(pathes)
    end
    describe "calling categories" do
      it "returns all products" do
        @service = XcMetricsAggregator::ProductsService.new
        products = @service.targets
        expect(products.count).to eq 3
        expect(products[0].bundle_id).to eq "app.bundle_id.foo"
        expect(products[1].bundle_id).to eq "app.bundle_id.bar"
        expect(products[2].bundle_id).to eq "app.bundle_id.foobar"
      end
    end
end