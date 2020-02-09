module XcMetricsAggregator
    module OutputFormat
        CSV = "csv"
        ASCII = "ascii"

        def self.all
            self.constants.map{|name| self.const_get(name) }
        end
    end
end