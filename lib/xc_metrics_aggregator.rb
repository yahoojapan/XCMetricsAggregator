require "xc_metrics_aggregator/version"
require 'xc_metrics_aggregator/product'
require 'xc_metrics_aggregator/crawler'
require 'xc_metrics_aggregator/service/devices_service'
require 'xc_metrics_aggregator/service/percentiles_service'
require 'xc_metrics_aggregator/service/categories_service'
require 'xc_metrics_aggregator/service/metrics_service'
require 'xc_metrics_aggregator/service/latest_service'
require 'xc_metrics_aggregator/formatter/formatter'
require 'xc_metrics_aggregator/formatter/output_format'
require 'thor'
require 'ascii_charts'
require 'pp'

module XcMetricsAggregator

  class Error < StandardError; end
  class CLI < Thor

    desc "crowl", "Aggregate raw data of Xcode Organizer Metrics"
    def crowl
      Crawler.execute()
    end

    desc "apps", "Shows available bundle ids on Xcode Organizer Metrics"
    option :available_path, type: :boolean, aliases: "-a", default: false
    option :format, aliases: "-f", type: :string, default: "ascii"
    def apps
      service = ProductsService.new 
      puts service.structure(options[:available_path]).format Formatter.get_formatter(format)
    end

    option :bundle_ids, :aliases => "-b", type: :array, default: []
    option :format, :aliases => "-f", type: :string, default: "ascii"
    desc "devices [-b <bundle id 1> <bundle id 2> ...] [-f <format>]", "Show available devices by builde id"
    def devices
      each_product do |product|
        product.try_to_open do |json| 
          puts DevicesService
            .new(product.bundle_id, json)
            .structure
            .format Formatter.get_formatter(format)
          puts "\n\n"
        end
      end
    end

    option :bundle_ids, :aliases => "-b", type: :array, default: []
    option :format, :aliases => "-f", type: :string, default: "ascii"
    desc "percentiles [-b <bundle id>,...] [-f <format>]", "Show available percentiles by builde id"
    def percentiles
      each_product do |product|
        product.try_to_open do |json| 
          puts PercentilesService
            .new(product.bundle_id, json)
            .structure
            .format Formatter.get_formatter(format)
          puts "\n\n"
        end
      end
    end

    
    option :bundle_id, :aliases => "-b", require: true
    option :format, :aliases => "-f", type: :string, default: "ascii"
    desc "categories -b <bundle id> [-f <format>]", "Show available categories by builde id"
    def sections
      product.try_to_open do |json|
        puts CategoriesService
          .new(product.bundle_id, json)
          .structure
          .format Formatter.get_formatter(format)
      end
    end
    
    option :section, :aliases => "-s", require: true
    option :bundle_id, :aliases => "-b", require: true
    option :format, :aliases => "-f", type: :string, default: "ascii"
    desc "metrics -b <bundle id> -s <section> [-f <format>]", "Show metrics data to a builde id"
    def metrics
      product.try_to_open do |json| 
        MetricsService
          .new(product.bundle_id, json)
          .structures(options[:section])
          .each do |structure|
            puts structure.format Formatter.get_formatter(format)
            puts "------\n\n"
          end
      end
    end

    option :section, :aliases => "-s", require: true
    option :device, :aliases => "-d", type: :string
    option :percentile, :aliases => "-p", type: :string
    option :format, :aliases => "-f", type: :string, default: "ascii"
    desc "latest -s <section> [-p <percentile id>] [-d <device id>] [-f <format>]", "Compare a latest version's metrics between available builde ids"
    def latest
      deviceid = options[:device]
      percentileid = options[:percentile]
      section = options[:section]

      puts LatestService
        .new(section, deviceid, percentileid)
        .structure
        .format Formatter.get_formatter(format)
    end

    private 
    def format
      OutputFormat.all.find { |v| v == options[:format] }
    end

    def each_product
      ProductsService.new.each_product(options[:bundle_ids]) { |product|
        yield product
      }
    end

    def product
      ProductsService.new.target options[:bundle_id]
    end
  end
end
