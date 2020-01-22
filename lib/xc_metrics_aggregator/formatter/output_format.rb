module XcMetricsAggregator
    module OutputFormat
        CSV = "csv"
        HTML = "html"
        ASCII = "ascii"

        def self.all
            self.constants.map{|name| self.const_get(name) }
        end
    end
end