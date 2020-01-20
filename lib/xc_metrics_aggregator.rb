require "xc_metrics_aggregator/version"
require 'xc_metrics_aggregator/product'
require 'xc_metrics_aggregator/crawler'
require 'xc_metrics_aggregator/metrics/devices_service'
require 'xc_metrics_aggregator/metrics/percentiles_service'
require 'xc_metrics_aggregator/metrics/categories_service'
require 'xc_metrics_aggregator/metrics/metrics_service'
require 'xc_metrics_aggregator/metrics/latest_service'
require 'xc_metrics_aggregator/formatter/formatter'
require 'thor'
require 'ascii_charts'
require 'pp'

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

    option :bundle_ids
    option :format
    desc "", ""
    def devices
      ProductsService.new.each_product(options[:bundle_ids] || []) do |product|
        product.try_to_open do |json| 
          puts XcMetricsAggregator::Metrics::DevicesService
            .new(product.bundle_id, json)
            .structure
            .format XcMetricsAggregator::Formatter.get_formatter(options[:format])
          puts "\n\n"
        end
      end
    end

    option :bundle_ids
    option :format
    desc "", ""
    def percentiles
      ProductsService.new.each_product(options[:bundle_ids] || []) do |product|
        product.try_to_open do |json| 
          puts XcMetricsAggregator::Metrics::PercentilesService
            .new(product.bundle_id, json)
            .structure
            .format XcMetricsAggregator::Formatter.get_formatter(options[:format])
          puts "\n\n"
        end
      end
    end

    
    option :bundle_id, require: true
    option :format
    desc "", ""
    def categories
      product = ProductsService.new.target options[:bundle_id]
      product.try_to_open do |json|
        puts XcMetricsAggregator::Metrics::CategoriesService
          .new(product.bundle_id, json)
          .structure
          .format XcMetricsAggregator::Formatter.get_formatter(options[:format])
      end
    end
    
    option :bundle_id, require: true
    option :section, require: true
    desc "", ""
    def metrics
      product = ProductsService.new.target options[:bundle_id]
      product.try_to_open do |json| 
        XcMetricsAggregator::Metrics::MetricsService
          .new(product.bundle_id, json).structures(options[:section])
          .each do |structure|
            puts structure.format XcMetricsAggregator::Formatter.get_formatter(options[:format])
            puts "------\n\n"
          end
      end
    end

    option :device, require: true
    option :percentile, require: true
    option :section, require: true
    option :format
    desc "", ""
    def latest
      deviceid = options[:device]
      percentileid = options[:percentile]
      section = options[:section]

      puts XcMetricsAggregator::Metrics::LatestService
        .new(section, deviceid, percentileid)
        .structure
        .format Formatter.get_formatter(options[:format])
    end
  end
end
