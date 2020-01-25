require 'spec_helper'

RSpec.describe "XCMetricsAggregator::ProductService" do
    pathes = ["/foo/foo/app.bundle_id.foo", "/foo/foo/app.bundle_id.bar",  "/foo/foo/app.bundle_id.foobar"]
    before do
        expect(Dir).to receive(:glob).and_return(pathes)
    end
    describe "calling products" do
      it "returns all products" do
        @service = XcMetricsAggregator::ProductsService.new
        products = @service.targets
        expect(products.count).to eq 3
        expect(products[0].bundle_id).to eq "app.bundle_id.foo"
        expect(products[1].bundle_id).to eq "app.bundle_id.bar"
        expect(products[2].bundle_id).to eq "app.bundle_id.foobar"
      end

      it "returns specified products" do
        @service = XcMetricsAggregator::ProductsService.new
        products = @service.targets ["app.bundle_id.foo", "app.bundle_id.bar"]
        expect(products.count).to eq 2
        expect(products[0].bundle_id).to eq "app.bundle_id.foo"
        expect(products[1].bundle_id).to eq "app.bundle_id.bar"
      end
    end

    describe "calling product" do
        it "returns a product" do
          @service = XcMetricsAggregator::ProductsService.new
          product = @service.target "app.bundle_id.bar"
          expect(product.bundle_id).to eq "app.bundle_id.bar"
        end
    end

    describe "calling each_product" do
        it "recieves block" do
          @service = XcMetricsAggregator::ProductsService.new
          product = @service.each_product do |product|
            expect(product.bundle_id).not_to be nil
          end
        end
    end

    describe "calling structure" do
        it "makes a structure without path" do
          @service = XcMetricsAggregator::ProductsService.new
          structure = @service.structure(false)
          expect(structure.title).to eq "available app list"
          expect(structure.headings).to eq ['bundle id', 'status']
          expect(structure.rows).to eq([
            ['app.bundle_id.foo', 'fail to get metrics'], 
            ['app.bundle_id.bar', 'fail to get metrics'],
            ['app.bundle_id.foobar', 'fail to get metrics']
          ])
        end

        it "makes a structure without path" do
            @service = XcMetricsAggregator::ProductsService.new
            structure = @service.structure(false)
            expect(structure.title).to eq "available app list"
            expect(structure.headings).to eq ['bundle id', 'status']
            expect(structure.rows).to eq([
              ['app.bundle_id.foo', 'fail to get metrics'], 
              ['app.bundle_id.bar', 'fail to get metrics'],
              ['app.bundle_id.foobar', 'fail to get metrics']
            ])
        end
    end
end