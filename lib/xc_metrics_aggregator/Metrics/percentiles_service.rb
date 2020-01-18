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
        def initialize(json)
            @json = json
        end
        
        def percentiles
            percentiles_json = @json["filterCriteriaSets"]["percentiles"]
            percentiles_json.map { |percentile_json| Percentile.new percentile_json }
        end

        def to_s
            rows = percentiles.map { |percentile| [percentile.display_name, percentile.identifier] }
            table = Terminal::Table.new :rows => rows
            table.to_s
        end
    end
end