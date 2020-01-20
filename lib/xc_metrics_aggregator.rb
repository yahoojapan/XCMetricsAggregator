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
      format_type = XcMetricsAggregator::Formatter.get_formatter(options[:format])
      ProductsService.new.each_product(options[:bundle_ids] || []) do |product|
        begin
          product.open do |json| 
            service = XcMetricsAggregator::Metrics::DevicesService.new(product.bundle_id, json)
            puts service.structure.format format_type
          end
        rescue
        end
      end
    end

    option :bundle_ids
    option :format
    desc "", ""
    def percentiles
      format_type = XcMetricsAggregator::Formatter.get_formatter(options[:format])
      ProductsService.new.each_product(options[:bundle_ids] || []) do |product|
        begin
          product.open do |json| 
            service = XcMetricsAggregator::Metrics::PercentilesService.new(product.bundle_id, json)
            puts service.structure.format format_type
          end
        rescue
        end
      end
    end

    
    option :bundle_id, require: true
    option :format
    desc "", ""
    def categories
      format_type = XcMetricsAggregator::Formatter.get_formatter(options[:format])
      product = ProductsService.new.target options[:bundle_id]
      begin
        product.open do |json| 
          service = XcMetricsAggregator::Metrics::CategoriesService.new(product.bundle_id, json)
          puts service.structure.format format_type
        end
      rescue => e
        puts e.backtrace
      end
    end
    
    option :bundle_id, require: true
    option :section, require: true
    desc "", ""
    def metrics
      format_type = XcMetricsAggregator::Formatter.get_formatter(options[:format])
      product = ProductsService.new.target options[:bundle_id]
      product.open do |json| 
        service = XcMetricsAggregator::Metrics::MetricsService.new(product.bundle_id, json)
        service.structures(options[:section]).each do |structure|
          puts structure.format format_type
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
      format_type = Formatter.get_formatter(options[:format])

      latest_service = XcMetricsAggregator::Metrics::LatestService.new section, deviceid, percentileid
      puts latest_service.structure.format format_type
    end
  end
end
