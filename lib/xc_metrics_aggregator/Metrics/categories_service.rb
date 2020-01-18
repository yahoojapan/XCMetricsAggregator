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
            @datasets = json["datasets"]
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

    class CategoriesService
        def initialize(json)
            @json = json
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
    end
end 