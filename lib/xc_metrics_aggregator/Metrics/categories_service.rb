require 'xc_metrics_aggregator/structure/structure'
require 'pp'
module XcMetricsAggregator::Metrics
    class CategoriesService
        attr_reader :device_service

        def initialize(bundle_id, json)
            @json = json
            @bundle_id = bundle_id
            @device_service = DevicesService.new bundle_id, json
        end

        def structure
            structure = XcMetricsAggregator::TableStructure.new
            structure.title = @bundle_id
            structure.headings = headings
            structure.rows = rows
            structure
        end

        def categories
            @json["categories"].map { |json| Category.new json }
        end

        def get_dataset(section_name, device, percentile)
            section = categories.map { |category| category.sections.find { |section| section.display_name == section_name } }.first
            section.datasets.find do |dataset| 
                dataset.filter_criteria.device == device.identifier \
                && dataset.filter_criteria.percentile == percentile.identifier
            end
        end


        def get_available_dataset(section_name, device, percentile)
            section = categories.map { |category| 
                category.sections.find { |section| 
                    section.display_name == section_name
                }
            }.flatten.compact.first
            if section.nil?
                return nil
            end

            datasets = section.datasets.select do |dataset| 
                available_device = device ? dataset.filter_criteria.device == device.identifier : true
                available_percentile = percentile ? dataset.filter_criteria.percentile == percentile.identifier : true
                available_device && available_percentile && !dataset.points.empty?
            end.last
            datasets
        end

        def get_section(section_name)
            section = categories.map { |category| 
                category.sections.find { |section| 
                    section.display_name == section_name
                }
            }.flatten.compact.first
            section
        end
                
        private
        def rows
            categories.map do |category| 
                [
                    category.display_name, 
                    category.sections.map{ |s| s.display_name }.join("\n"), 
                    category.sections.map{ |s| s.unit.display_name }.join("\n")
                ] 
            end
        end

        def headings
            ["category", "section", "unit"]
        end
    end
end 


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

        def self.new_from_prop(device, percentile)
            self.new({"device": device.identifier, "percentile": percentile.identifier})
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
end