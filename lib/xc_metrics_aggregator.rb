require "xc_metrics_aggregator/version"
require 'xc_metrics_aggregator/product'
require 'xc_metrics_aggregator/crawler'
require 'xc_metrics_aggregator/metrics/devices_service'
require 'xc_metrics_aggregator/metrics/percentiles_service'
require 'thor'

module XcMetricsAggregator
  ROOT_DIR = File.expand_path("..", __dir__)

  class Error < StandardError; end
  class CLI < Thor

    desc "", ""
    def crowl
      Crawler.execute()
    end

    desc "", ""
    def apps
      service = ProductsService.new
      puts service
    end

    desc "", ""
    def devices(*bundle_ids)
      ProductsService.new.each_product(bundle_ids || []) do |product|
        begin
          product.open { |json| puts "#{product.bundle_id}:\n#{XcMetricsAggregator::Metrics::DevicesService.new json}\n\n" }
        rescue 
        end
      end
    end

    desc "", ""
    def percentiles(*bundle_ids)
      ProductsService.new.each_product(bundle_ids || []) do |product|
        begin
          product.open { |json| 
            puts "#{product.bundle_id}:\n#{XcMetricsAggregator::Metrics::PercentilesService.new json}\n\n" 
          }
        rescue
        end
      end
    end
  end
end
