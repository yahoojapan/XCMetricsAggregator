require 'terminal-table'

module XcMetricsAggregator::Metrics
    class Category
        attr_accessor :sections, :display_name, :identifier

        def initialize(json)
            @sections = json["sections"].map { |section| Section.new section }
            @display_name = json["displayName"]
            @identifier = json["identifier"]
        end
    end

    class Section
        attr_accessor :datasets, :display_name, :identifier, :unit

        def initialize(json)
            @datasets = json["datasets"].map { |d| DataSet.new d }
            @unit = Unit.new json["unit"]
            @display_name = json["displayName"]
            @identifier = json["identifier"]
        end
    end

    class Unit
        attr_accessor :display_name, :identifier

        def initialize(json)
            @display_name = json["displayName"]
            @identifier = json["identifier"]
        end
    end

    class FilterCriteria
        attr_accessor :device, :percentile

        def initialize(json)
            @device = json["device"]
            @percentile = json["percentile"]
        end

        def ==(other)
            device == other.device && percentile == other.percentile
        end
    end

    class Point
        attr_accessor :summary, :version, :percentage_breakdown

        def initialize(json)
            @summary = json["summary"]
            @version = json["version"]
            @percentage_breakdown = json["percentageBreakdown"]
        end
    end

    class DataSet
        attr_accessor :points, :filter_criteria

        def initialize(json)
            @points = json["points"].map { |p| Point.new p }
            @filter_criteria = FilterCriteria.new json["filterCriteria"]
        end
    end

    class CategoriesService
        def initialize(json)
            @json = json
            @device_service = DevicesService.new json
        end

        def lookup
            categories.map do |category| 
                [category.display_name, category.sections.map{ |s| s.display_name }.join("\n"), category.sections.map{ |s| s.unit.display_name }.join("\n")] 
            end
        end

        def headings
            ["category", "section", "unit"]
        end

        def categories
            @json["categories"].map { |json| Category.new json }
        end

        def datasets(section_name)
            section = categories.map do |category|
                category.sections.select do |section|
                    section.display_name == section_name
                end
            end.flatten.first
            p section.datasets

            section.datasets
        end

        def formatted_datasets(section_name)
            outputs = []
            datasets(section_name).each do |dataset|
                chart_data = dataset.points.map { |point| [point.version, point.summary] }

                device = @device_service.get_device dataset.filter_criteria.device
                outputs << {meta: [["device", device.display_name], ["percentile", dataset.filter_criteria.percentile]], chart_data: chart_data }
            end
            outputs
        end

        def formatted_datasets(section_name)
            outputs = []
            datasets(section_name).each do |dataset|
                chart_data = dataset.points.map { |point| [point.version, point.summary] }

                device = @device_service.get_device dataset.filter_criteria.device
                outputs << {meta: [["device", device.display_name], ["percentile", dataset.filter_criteria.percentile]], chart_data: chart_data }
            end
            outputs
        end
    end
end 