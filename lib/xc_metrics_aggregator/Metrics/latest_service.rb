require 'xc_metrics_aggregator/structure/structure'

module XcMetricsAggregator::Metrics
    class LatestService
        def initialize(section, deviceid, percentileid)
            target_datasets = {}
            unit_label = ""
            each_product do |product|
                product.try_to_open do |json| 
                    device = get_device(product, json, deviceid)
                    percentile = get_percentile(product, json, percentileid)
                    
                    if device && percentile
                        dataset = get_dataset(product, json, section, device, percentile)
                    else
                        dataset = get_available_dataset(product, json, section, device, percentile)
                    end

                    unless dataset.nil? || dataset.points.empty?
                      unit_label = get_unit_label(product, json, section)
                      target_datasets[product.bundle_id] = dataset
                    end
                end
            end
            @unit_label = unit_label
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

        private
        def each_product
            XcMetricsAggregator::ProductsService.new.each_product do |product|
                yield product
            end
        end

        def get_device(product, json, deviceid)
            DevicesService.new(product.bundle_id, json).get_device deviceid
        end

        def get_percentile(product, json, percentileid)
            PercentilesService.new(product.bundle_id, json).get_percentile percentileid
        end

        def get_category_service(product, json)
            CategoriesService.new(product.bundle_id, json) 
        end

        def get_dataset(product, json, section, device, percentile)
            get_category_service(product, json).get_dataset section, device, percentile
        end

        def get_available_dataset(product, json, section, device, percentile)
            get_category_service(product, json).get_available_dataset section, device, percentile
        end

        def get_unit_label(product, json, section)
            get_category_service(product, json).get_section(section).unit.display_name
        end
    end
end