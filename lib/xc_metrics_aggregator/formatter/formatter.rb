require 'terminal-table'
require 'xc_metrics_aggregator/structure/structure'
require 'xc_metrics_aggregator/formatter/output_format'


module XcMetricsAggregator
    class Formatter
        def self.get_formatter(format)
            case format
            when OutputFormat::CSV
                CSVFormatter.new
            when OutputFormat::HTML
                HTMLFormatter.new
            when OutputFormat::ASCII, nil
                ASCIIFormatter.new
            end
        end

        def format(data)
            case data
            when TableStructure
                format_table(data)
            when ChartStructure
                format_chart(data)
            end
        end

        def format_table(data)
        end

        def format_chart(data)
        end
    end
    
    class CSVFormatter < Formatter
        def format_table(data)
        end

        def format_chart(data)
        end
    end

    class HTMLFormatter < Formatter
        def format_table(data)
        end

        def format_chart(data)
            
        end
    end

    class ASCIIFormatter < Formatter
        def format_table(data)
            Terminal::Table.new rows: data.rows, headings: data.headings, title: data.title
        end

        def format_chart(data)
            output = Terminal::Table.new(rows: data.series.rows, headings: data.series.headings).to_s
            output += "\n"
            output += AsciiCharts::Cartesian.new(data.samples, bar: true, hide_zero: true).draw.to_s
            output += "\n"
            output += "Unit: #{data.unit}\n\n"
        end
    end
end