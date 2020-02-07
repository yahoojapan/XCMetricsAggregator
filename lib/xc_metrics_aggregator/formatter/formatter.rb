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
            when OutputFormat::ASCII
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
            output = data.headings.join(',') + "\n"
            data.rows.each do |row|
                if row == :separator
                    next
                end

                sub_rows = row.map { |e| e.split("\n") }
                max_sub_row = sub_rows.max { |a, b| a.count <=> b.count }
                expaneded_sub_rows = sub_rows.map do |sub_row|
                    unit = max_sub_row.count / sub_row.count
                    mod = max_sub_row.count.modulo sub_row.count
                    expanded_sub_row = sub_row.map { |sub_row_e| Array.new(unit, sub_row_e) }.flatten
                    if sub_row.last
                        expanded_sub_row += Array.new(mod, sub_row.last)
                    end
                    expanded_sub_row
                end
                output += expaneded_sub_rows
                    .transpose
                    .map do |row| 
                        row.map{ |e| e.include?(",") ? "\"#{e}\"" : e }
                          .join(',')
                    end
                    .join("\n")
                output += "\n"
            end
            output
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