require 'xc_metrics_aggregator/structure/structure'

module XcMetricsAggregator::Metrics
    class LatestService

        def initialize(section, deviceid, percentileid)
            target_datasets = {}
            unit_label = ""
            XcMetricsAggregator::ProductsService.new.each_product do |product|
                product.try_to_open do |json| 
                    device = XcMetricsAggregator::Metrics::DevicesService.new(product.bundle_id, json).get_device deviceid
                    percentile = XcMetricsAggregator::Metrics::PercentilesService.new(product.bundle_id, json).get_percentile percentileid
                    category_service = XcMetricsAggregator::Metrics::CategoriesService.new(product.bundle_id, json) 
                    
                    dataset = category_service.get_dataset section, device, percentile
                    unless dataset.nil? || dataset.points.empty?
                      unit_label = category_service.get_section(section).unit.display_name
                      target_datasets[product.bundle_id] = dataset
                    end
                end
            end
            
            @unit_labe = unit_label
            @target_datasets = target_datasets
        end

        def structure
            structure = XcMetricsAggregator::ChartStructure.new
            structure.series = series
            structure.samples = samples
            structure.unit = @unit_label
            return structure
        end

        private
        def samples
            @target_datasets.keys.each_with_index.reduce([]) do |sum, (bundle_id, idx)|
              dataset = @target_datasets[bundle_id]
              if dataset.points.empty?
                sum
              else
                latest_point = dataset.points.last
                sum + [[idx, latest_point.summary]]
              end
            end
        end

        def series
          structure = XcMetricsAggregator::TableStructure.new
          structure.headings = ["Label", "Bundle ID", "Version"]
          structure.rows = @target_datasets.keys.each_with_index.map do |bundle_id, idx|
            latest_point = @target_datasets[bundle_id].points.last
            [idx, bundle_id, latest_point.version]
          end
          structure
        end
    end
end