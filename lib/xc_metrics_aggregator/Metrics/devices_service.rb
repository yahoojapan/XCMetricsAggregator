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
        def initialize(bundle_id, json)
            @json = json
            @bundle_id = bundle_id
        end
        
        def devicefamilies
            device_families_json = @json["filterCriteriaSets"]["deviceFamilies"]
            device_families_json.map do |device_family_json|
                DeviceFamily.new device_family_json
            end
        end

        def structure
            structure = XcMetricsAggregator::TableStructure.new
            structure.title = @bundle_id
            structure.headings = headings()
            structure.rows = rows()
            structure
        end

        def get_device(identifier)
            devicefamilies.select do |devicefamily| 
                devicefamily.devices.select do |device|
                    device.identifier == identifier
                end
            end.flatten.first
        end

        private
        def rows
            rows = []
            devicefamilies.each_with_index do |devicefamily, idx| 
                device_display_names = devicefamily.devices.map{ |d| d.display_name }.join("\n")
                device_identifiers = devicefamily.devices.map{ |d| d.identifier }.join("\n")
                row = [devicefamily.display_name, device_display_names, device_identifiers]
                rows += if idx == devicefamilies.count - 1
                    [row]
                else
                    [row] + [:separator]
                end
            end
            return rows
        end

        def headings
            ["kind", "device", "id"]
        end
    end
end