require "xc_metrics_aggregator/version"
require 'xc_metrics_aggregator/product'
require 'xc_metrics_aggregator/crawler'
require 'xc_metrics_aggregator/metrics/devices_service'
require 'xc_metrics_aggregator/metrics/percentiles_service'
require 'xc_metrics_aggregator/metrics/categories_service'
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

    desc "", ""
    def devices(*bundle_ids)
      ProductsService.new.each_product(bundle_ids || []) do |product|
        begin
          product.open do |json| 
            service = XcMetricsAggregator::Metrics::DevicesService.new(json)
            rows = service.lookup
            t =  Terminal::Table.new do |t|
              t.title = product.bundle_id
              t.headings = service.headings
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
            service = XcMetricsAggregator::Metrics::PercentilesService.new(json)
            rows = service.lookup
            t =  Terminal::Table.new do |t|
              t.title = product.bundle_id
              t.headings = service.headings
              rows.each_with_index do |r, i|
                t << r
                if i != rows.count - 1
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
    def categories(bundle_id)
      product = ProductsService.new.target bundle_id
      begin
        product.open do |json| 
          service = XcMetricsAggregator::Metrics::CategoriesService.new(json)
          rows = service.lookup
          t =  Terminal::Table.new do |t|
            t.headings = service.headings
            t.title = product.bundle_id
            rows.each do |r|
              t << r
            end
          end
          puts "#{t}\n\n" 
        end
      rescue => e
        puts e
      end
    end

    desc "", ""
    def lookup(bundle_id)
      puts "\n\n######### #{bundle_id} ##########\n\n"

      product = ProductsService.new.target bundle_id
      begin
        product.open do |json| 
          service = XcMetricsAggregator::Metrics::DevicesService.new(json)
          rows = service.lookup
          t =  Terminal::Table.new do |t|
            t.title = "device"
            t.headings = service.headings
            rows.each_with_index do |r, i|
              t << r
              if i != rows.count - 1
                t << :separator
              end
            end
          end
          puts "#{t}\n\n" 
        end

        product.open do |json| 
          service = XcMetricsAggregator::Metrics::PercentilesService.new(json)
          rows = service.lookup
          t =  Terminal::Table.new do |t|
            t.title = "percentile"
            t.headings = service.headings
            rows.each_with_index do |r, i|
              t << r
              if i != rows.count - 1
              end
            end
          end
          puts "#{t}\n\n" 
        end

        product.open do |json| 
          service = XcMetricsAggregator::Metrics::CategoriesService.new(json)
          rows = service.lookup
          t =  Terminal::Table.new do |t|
            t.headings = service.headings
            t.title = "category"
            rows.each do |r|
              t << r
            end
          end
          puts "#{t}\n\n" 
        end
      rescue => e
        puts e
      end
    end
    
    desc "", ""
    def metrics(category, bundle_id)
      product = ProductsService.new.target bundle_id
      product.open do |json| 
        service = XcMetricsAggregator::Metrics::CategoriesService.new(json)
        datasets = service.formatted_datasets(category)
        datasets.each do |dataset|
          puts AsciiCharts::Cartesian.new(dataset[:chart_data], :bar => true, :hide_zero => true).draw
          puts Terminal::Table.new rows: dataset[:meta]
          puts "\n\n\n------\n\n\n"
        end
      end
    end

    option :device, require: true
    option :percentile, require: true
    desc "", ""
    def latest(section)
      deviceid = options[:device]
      percentileid = options[:percentile]

      product_service = ProductsService.new

      target_datasets = {}
      unit_label = ""
      product_service.each_product do |product|
        begin
          product.open do |json| 
            device = XcMetricsAggregator::Metrics::DevicesService.new(json).get_device deviceid
            percentile = XcMetricsAggregator::Metrics::PercentilesService.new(json).get_percentile percentileid
            category_service = XcMetricsAggregator::Metrics::CategoriesService.new(json) 
            dataset = category_service.get_dataset section, device, percentile
            unless dataset.nil? || dataset.points.empty?
              unit_label = category_service.get_section(section).unit.display_name
              target_datasets[product.bundle_id] = dataset
            end
          end
        rescue
        end
      end

      
      chart_data = target_datasets.keys.each_with_index.reduce([]) do |sum, (bundle_id, idx)|
        dataset = target_datasets[bundle_id]
        if dataset.points.empty?
          sum
        else
          latest_point = dataset.points.last
          sum + [[idx, latest_point.summary]]
        end
      end

      series = target_datasets.keys.each_with_index.map do |bundle_id, idx|
        latest_point = target_datasets[bundle_id].points.last
        [idx, bundle_id, latest_point.version]
      end

      puts "\n\n**** #{section} ****\n\n"
      puts Terminal::Table.new rows: series, headings: ["Label", "Bundle ID", "Version"]
      puts AsciiCharts::Cartesian.new(chart_data, bar: true, hide_zero: true).draw
      puts "Unit: #{unit_label}\n\n"
    end
  end
end
