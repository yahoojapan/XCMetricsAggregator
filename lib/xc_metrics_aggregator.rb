require "xc_metrics_aggregator/version"
require 'xc_metrics_aggregator/product'
require 'xc_metrics_aggregator/crowler'
require 'xc_metrics_aggregator/metrics/devices_service'
require 'thor'

module XcMetricsAggregator
  ROOT_DIR = File.expand_path("..", __dir__)

  class Error < StandardError; end
  class CLI < Thor

    desc "", ""
    def crowl
      Crowler.execute()
    end

    desc "", ""
    def devices(*bundle_ids)
      products_provider = ProductsProvider.new

      target_products = []
      if bundle_ids.empty?
        target_products = products_provider.products
      else
        target_products = products_provider.products.select do |product|
           bundle_ids.include? product.bundle_id.to_s
        end
      end

      target_products.each do |product|
        begin
          product.json do |json|
            service = XcMetricsAggregator::Metrics::DevicesService.new json
            puts "#{product.bundle_id}:\n"
            puts service
            puts "\n"
          end
        rescue
        end
      end
    end

    desc "", ""
    def apps
      products_provider = ProductsProvider.new
      puts products_traverser
    end
  end
end
