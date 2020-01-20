require 'xc_metrics_aggregator/structure/structure'

module XcMetricsAggregator::Metrics
    class Percentile
        attr_accessor :display_name, :is_represented, :identifier
        
        def initialize(json)
            @is_represented = json["isRepresented"]
            @display_name = json["displayName"]
            @identifier = json["identifier"]
        end
    end

    class PercentilesService
        def initialize(bundle_id, json)
            @json = json
            @bundle_id = bundle_id
        end
        
        def percentiles
            percentiles_json = @json["filterCriteriaSets"]["percentiles"]
            percentiles_json.map { |percentile_json| Percentile.new percentile_json }
        end
        
        def structure
            structure = XcMetricsAggregator::TableStructure.new
            structure.title = @bundle_id
            structure.headings = headings()
            structure.rows = rows()
            structure
        end
        
        def rows
            percentiles.map { |percentile| [percentile.display_name, percentile.identifier] }
        end

        def headings
            ["percentile", "id"]
        end

        def get_percentile(identifier)
            percentiles.find do |percentile| 
                percentile.identifier = identifier
            end
        end
    end
end