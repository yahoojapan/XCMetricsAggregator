require 'xc_metrics_aggregator/service/categories_service'
require 'xc_metrics_aggregator/structure/structure'

module XcMetricsAggregator
    class MetricsService
        def initialize(bundle_id, json)
            @bundle_id = bundle_id
            @category_service = CategoriesService.new bundle_id, json
        end

        def structures(section_name, device_id, percentile_id, version)
            rows = []
            samples = [] 
            index = 0
            datasets(section_name).each do |dataset|
                device_identifier =  dataset.filter_criteria.device
                validated_device = !device_id || device_identifier == device_id
                percentile_identifier =  dataset.filter_criteria.percentile
                validated_percentile = !percentile_id || percentile_identifier == percentile_id

                unless validated_device && validated_percentile
                    next
                end


                device = @category_service.device_service.get_device dataset.filter_criteria.device
                rows += dataset.points.map.with_index(index) { |p, i| [i, p.version, device.display_name, dataset.filter_criteria.percentile] }
                samples += dataset.points.map.with_index(index) { |p, i| [i, p.summary] }
                index += dataset.points.count
            end

            table_structure = XcMetricsAggregator::TableStructure.new
            table_structure.headings = ["Label", "Version", "Device", "Percentile"]
            table_structure.title = section_name
            table_structure.rows = rows
            structure = XcMetricsAggregator::ChartStructure.new
            structure.series = table_structure
            structure.unit = @category_service.get_section(section_name).unit.display_name
            structure.samples = samples

            structure
        end

        def datasets(section_name)
            section = @category_service.get_section(section_name)
            unless section
                raise StandardError.new("wrong section name")
            end
            section.datasets
        end
    end
end