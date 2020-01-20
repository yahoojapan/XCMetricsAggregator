require 'terminal-table'

module XcMetricsAggregator
    class Formatter
        def self.get_formatter(option)
            case option
            when "csv"
                CSVFormatter.new
            when "html"
                HTMLFormatter.new
            when "ascii", nil
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
            Terminal::Table.new rows: data.rows, heading: data.headings, title: data.title
        end

        def format_chart(data)
            output = Terminal::Table.new(rows: data.series.rows, headings: data.series.headings).to_s
            output += "\n"
            output += AsciiCharts::Cartesian.new(data.samples, bar: true, hide_zero: true).draw.to_s
            output += "\n"
            output += "Unit: #{data.unit}\n\n"
        end
    end


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