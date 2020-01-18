require 'terminal-table'

module XcMetricsAggregator::Metrics
    class Device
        attr_accessor :is_represented, :display_name, :identifier

        def initialize(json)
            @is_represented = json["isRepresented"]
            @display_name = json["displayName"]
            @identifier = json["identifier"]
        end
    end

    class DeviceFamily
        attr_accessor :is_represented, :display_name, :identifier, :devices

        def initialize(json)
            @is_represented = json["isRepresented"]
            @display_name = json["displayName"]
            @identifier = json["identifier"]
            @devices = json["devices"].map { |json| Device.new json }
        end
    end


    class DevicesService
        def initialize(json)
            @json = json
        end
        
        def devicefamilies
            device_families_json = @json["filterCriteriaSets"]["deviceFamilies"]
            device_families_json.map do |device_family_json|
                DeviceFamily.new device_family_json
            end
        end

        def to_s
            rows = devicefamilies.map do |devicefamily| 
                [devicefamily.display_name, devicefamily.devices.map{ |d| d.display_name }.join("\n")] 
            end
            table = Terminal::Table.new :rows => rows
            table.to_s
        end
    end
end