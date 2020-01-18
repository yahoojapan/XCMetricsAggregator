require "xc_metrics_aggregator/version"
require 'xc_metrics_aggregator/product'
require 'xc_metrics_aggregator/crawler'
require 'xc_metrics_aggregator/metrics/devices_service'
require 'xc_metrics_aggregator/metrics/percentiles_service'
require 'xc_metrics_aggregator/metrics/categories_service'
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
          product.open do |json| 
            rows = XcMetricsAggregator::Metrics::DevicesService.new(json).lookup
            t =  Terminal::Table.new do |t|
              t.title = product.bundle_id
              rows.each_with_index do |r, i|
                t << r
                if i != rows.count - 1
                  t << :separator
                end
              end
            end
            puts "#{t}\n\n" 
          end
        rescue 
        end
      end
    end

    desc "", ""
    def percentiles(*bundle_ids)
      ProductsService.new.each_product(bundle_ids || []) do |product|
        begin
          product.open do |json| 
            rows = XcMetricsAggregator::Metrics::PercentilesService.new(json).lookup
            t =  Terminal::Table.new do |t|
              t.title = product.bundle_id
              rows.each_with_index do |r, i|
                t << r
                if i != rows.count - 1
                  t << :separator
                end
              end
            end
            puts "#{t}\n\n" 
          end
        rescue
        end
      end
    end

    desc "", ""
    def lookup(bundle_id)
        product = ProductsService.new.target bundle_id
        begin
          product.open do |json| 
            rows = XcMetricsAggregator::Metrics::CategoriesService.new(json).lookup
            t =  Terminal::Table.new do |t|
              t.title = product.bundle_id
              rows.each_with_index do |r, i|
                t << r
                if i != rows.count - 1
                  t << :separator
                end
              end
            end
            puts "#{t}\n\n" 
          end
        rescue 
        end
    end

    desc "", ""
    def metrics(category, bundle_id)
      
    end
  end
end
