require 'xc_metrics_aggregator/formatter/formatter'

module XcMetricsAggregator
    class Structure
        def format(formatter)
            formatter.format(self)
        end
    end

    class TableStructure < Structure
        attr_accessor :title, :headings, :rows
    end

    class ChartStructure < Structure
        attr_accessor :series, :samples, :unit
    end
end