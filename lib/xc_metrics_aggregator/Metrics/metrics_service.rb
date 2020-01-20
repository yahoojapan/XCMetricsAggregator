require 'xc_metrics_aggregator/metrics/categories_service'

module XcMetricsAggregator::Metrics
    class MetricsService
        def initialize(bundle_id, json)
            @bundle_id = bundle_id
            @category_service = CategoriesService.new bundle_id, json
        end

        def structures(section_name)
            structures = []
            datasets(section_name).each do |dataset|
                device = @category_service.device_service.get_device dataset.filter_criteria.device
                structure = XcMetricsAggregator::ChartStructure.new
                table_structure = XcMetricsAggregator::TableStructure.new
                table_structure.rows = [["device", device.display_name], ["percentile", dataset.filter_criteria.percentile]]
                table_structure.headings = []
                table_structure.title = section_name
                structure.series = table_structure
                structure.unit = @category_service.get_section(section_name).unit.display_name
                samples = dataset.points.map { |point| [point.version, point.summary] }
                structure.samples = samples 
                structures << structure
            end
            structures
        end

        def datasets(section_name)
            @category_service.get_section(section_name).datasets
        end
    end
end